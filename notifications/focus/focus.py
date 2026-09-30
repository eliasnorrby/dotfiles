#!/usr/bin/env python3
"""focus: a pomodoro timer that holds notifications while you work.

Focus turns swaync's do-not-disturb on, so whatever arrives collects in the
control center instead of popping up; the break turns it off and chimes, and
a headless Claude session (the break brief, brief.md) says whether anyone
wrote to you during the focus with something that can't wait. The break starts on its own when focus
ends. The next focus waits for you: hyper+S or a click on the waybar module.
Every fourth break is a long one.

    focus toggle          idle or break -> start focus; focus -> break now
    focus start [MINUTES] start focus (a break in progress ends now)
    focus stop            back to idle from any phase, dnd off, cycle reset
    focus skip            end the current phase now
    focus brief [HOURS]   run the break brief now (the break runs it itself),
                          over the last HOURS instead of since the last brief
    focus seen            you have read Slack yourself: the next brief starts
                          from now
    focus status          one line for a terminal
    focus phase           print focus, break or idle (for other scripts)
    focus waybar          JSON for the waybar module; also applies a due
                          transition, as a fallback for the timer
    focus tick            apply a due transition (run by a transient systemd
                          timer at the end of each phase)

Other scripts read the phase: claude_notification keeps quiet during focus
unless its pane is the one being looked at, and tmux (`@focus`, set here)
hides the bell highlight until the break.

Files, under $XDG_STATE_HOME/focus: state.json; log.jsonl with one line per
finished phase (planned and actual length, whether it was cut short) and one
per brief (verdict, cost, duration), for tuning the lengths and reviewing the
briefs' calls; briefs/ with each brief's full text. Config in
~/.config/focus/config.toml.
"""

import fcntl
import json
import os
import re
import shutil
import subprocess
import sys
import time
import tomllib
from datetime import datetime

DEFAULTS = {
    "focus": 25, "break": 5, "long_break": 15, "long_break_every": 4,
    "brief": {
        "enabled": True, "model": "sonnet", "slack_user": "",
        "max_budget_usd": 1.5, "timeout_seconds": 240,
    },
}
SOUNDS = "/usr/share/sounds/freedesktop/stereo"
CHIME = {"break": f"{SOUNDS}/complete.oga", "idle": f"{SOUNDS}/bell.oga"}
TIMER_UNIT = "focus-tick"
BRIEF_UNIT = "focus-brief"
WAYBAR_SIGNAL = 9  # custom/focus listens on RTMIN+9
ICONS = {"focus": "\U000f051b", "break": "\U000f0176", "idle": "\U000f051b"}  # timer, coffee
# What a state carries across phases: the position in the cycle, and where
# the last brief left off.
CARRIED = ("count", "last_brief")
IDLE = {"phase": "idle", "count": 0}

# The brief's Slack tools, under either of the names the MCP server goes by
# (the claude.ai connector in a headless session, the plugin in a terminal).
SLACK_TOOLS = [
    f"mcp__{server}__slack_{tool}"
    for server in ("claude_ai_Slack", "plugin_slack_slack")
    for tool in (
        "search_public_and_private", "search_public", "read_channel", "read_thread",
        "search_channels", "search_users", "read_user_profile", "send_message",
    )
]
VERDICT_SCHEMA = {
    "type": "object",
    "properties": {
        "verdict": {"type": "string", "enum": ["clear", "attention"]},
        "headline": {"type": "string"},
        "items": {"type": "integer"},
        "link": {"type": "string"},
        "error": {"type": "string"},
    },
    "required": ["verdict", "headline"],
}


def xdg(kind, default):
    return os.environ.get(f"XDG_{kind}_HOME") or os.path.expanduser(default)


STATE_DIR = os.path.join(xdg("STATE", "~/.local/state"), "focus")
STATE = os.path.join(STATE_DIR, "state.json")
LOG = os.path.join(STATE_DIR, "log.jsonl")
BRIEFS = os.path.join(STATE_DIR, "briefs")
CONFIG = os.path.join(xdg("CONFIG", "~/.config"), "focus", "config.toml")
BRIEF_TEMPLATE = os.path.join(os.path.dirname(os.path.realpath(__file__)), "brief.md")


# -- plumbing -----------------------------------------------------------------


def config():
    try:
        with open(CONFIG, "rb") as handle:
            loaded = tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError):
        loaded = {}
    return {**DEFAULTS, **loaded, "brief": {**DEFAULTS["brief"], **loaded.get("brief", {})}}


def read_state():
    try:
        with open(STATE, encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, ValueError):
        return dict(IDLE)


def write_state(state):
    os.makedirs(STATE_DIR, exist_ok=True)
    temporary = f"{STATE}.tmp.{os.getpid()}"
    with open(temporary, "w", encoding="utf-8") as handle:
        json.dump(state, handle)
    os.replace(temporary, STATE)


def next_state(previous, **fields):
    """A new phase, keeping what carries across phases."""
    state = {key: previous[key] for key in CARRIED if key in previous}
    state.update(fields)
    return state


def log(line):
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(LOG, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(line) + "\n")


def log_phase(state, ended, cut_short):
    """One line per finished phase, the data for tuning the lengths."""
    log({
        "phase": state["phase"],
        "started": iso(state["started"]),
        "ended": iso(ended),
        "planned_min": state["planned"],
        "actual_min": round((ended - state["started"]) / 60, 1),
        "cut_short": cut_short,
        "n": state["count"],
        "long": state.get("long", False),
    })


def iso(epoch):
    return datetime.fromtimestamp(epoch).isoformat(timespec="seconds")


def run(*command, **kwargs):
    """A side effect that must not take the timer down with it: the desktop
    may be missing a piece (no swaync, no tmux server), and then the rest
    still happens."""
    try:
        return subprocess.run(command, check=False, capture_output=True, text=True, timeout=10, **kwargs)
    except (OSError, subprocess.TimeoutExpired):
        return None


def dnd(on):
    run("swaync-client", "-dn" if on else "-df", "-sw")


def tmux_focus(on):
    run("tmux", "set", "-g", "@focus", "1") if on else run("tmux", "set", "-gu", "@focus")


def chime(phase):
    """Waits for the sound: in a transient unit, a child left behind is
    killed when the unit's main process exits."""
    if os.path.exists(CHIME[phase]):
        run("paplay", CHIME[phase])


def notify(title, body="", urgency="normal"):
    run("notify-send", "-a", "focus", "-u", urgency, title, body)


def refresh_waybar():
    run("pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "-x", "waybar")


def transient(unit, *command, on_active=None):
    """Run a command as a transient user unit, so it outlives this process
    and shows up in systemctl. Each gets its own name: a tick runs inside
    the service its timer started, so a fixed name would collide with the
    running one, and stopping "the old unit" would stop us. The user
    manager's PATH is whatever it happened to import, so ours goes along."""
    name = f"{unit}-{int(time.time() * 1000)}"
    timer = [f"--on-active={max(1, int(on_active))}", "--timer-property=AccuracySec=1s"] if on_active else []
    run("systemd-run", "--user", "--quiet", "--collect", f"--unit={name}", f"--setenv=PATH={path()}", *timer,
        sys.executable, os.path.abspath(__file__), *command)


def path():
    """PATH with the directories the units need, wherever we were started."""
    wanted = [os.path.expanduser("~/.local/bin"), os.path.dirname(shutil.which("claude") or "/usr/bin/claude")]
    return os.pathsep.join(dict.fromkeys([*wanted, *os.environ.get("PATH", "").split(os.pathsep)]))


def cancel(unit, services=False):
    """Stop the unit's pending timers, and its running services only when
    asked: the service running us may be one of them."""
    run("systemctl", "--user", "stop", "--quiet", f"{unit}-*.timer", *([f"{unit}-*.service"] if services else []))


def schedule_tick(seconds):
    """A transient timer fires `focus tick` when the phase ends; the waybar
    poll applies the transition too, in case the timer doesn't."""
    cancel(TIMER_UNIT)
    transient(TIMER_UNIT, "tick", on_active=seconds)


class locked:
    """One transition at a time: the timer and waybar's poll both see a
    phase end, and only the first may act on it. Re-read the state inside."""

    def __enter__(self):
        os.makedirs(STATE_DIR, exist_ok=True)
        self.handle = open(os.path.join(STATE_DIR, "lock"), "w")
        fcntl.flock(self.handle, fcntl.LOCK_EX)
        return self

    def __exit__(self, *_):
        fcntl.flock(self.handle, fcntl.LOCK_UN)
        self.handle.close()


# -- transitions --------------------------------------------------------------


def start(state, minutes=None):
    now = time.time()
    if state["phase"] == "focus":
        return state, "already focusing"
    if state["phase"] == "break":
        log_phase(state, now, cut_short=True)
        if state.get("long"):
            state["count"] = 0
    minutes = minutes or config()["focus"]
    state = next_state(state, phase="focus", started=now, ends=now + minutes * 60, planned=minutes)
    state.setdefault("count", 0)
    write_state(state)
    dnd(True)
    tmux_focus(True)
    schedule_tick(minutes * 60)
    refresh_waybar()
    return state, f"focus for {minutes} min"


def end_focus(state, cut_short):
    """Focus ends: the break starts on its own, the chime says so, and the
    brief goes to work."""
    now = time.time()
    log_phase(state, now, cut_short)
    settings = config()
    count = state["count"] + 1
    long = settings["long_break_every"] > 0 and count % settings["long_break_every"] == 0
    minutes = settings["long_break"] if long else settings["break"]
    state = next_state(state, phase="break", started=now, ends=now + minutes * 60, planned=minutes, count=count, long=long)
    write_state(state)
    dnd(False)
    tmux_focus(False)
    chime("break")
    schedule_tick(minutes * 60)
    if settings["brief"]["enabled"]:
        cancel(BRIEF_UNIT, services=True)  # a brief still running from the last break is stale
        transient(BRIEF_UNIT, "brief")
    refresh_waybar()
    return state, f"{'long ' if long else ''}break for {minutes} min"


def end_break(state, cut_short):
    """The break ends with a nudge; the next focus waits for the hotkey."""
    now = time.time()
    log_phase(state, now, cut_short)
    state = next_state(state, phase="idle", count=0 if state.get("long") else state["count"])
    write_state(state)
    if cut_short:
        cancel(TIMER_UNIT)
    else:
        chime("idle")
        notify("Break over", "hyper+S starts the next focus")
    refresh_waybar()
    return state, "idle"


def stop(state):
    now = time.time()
    if state["phase"] != "idle":
        log_phase(state, now, cut_short=True)
    state = next_state(state, phase="idle", count=0)
    write_state(state)
    cancel(TIMER_UNIT)
    dnd(False)
    tmux_focus(False)
    refresh_waybar()
    return state, "stopped"


def skip(state):
    if state["phase"] == "focus":
        return end_focus(state, cut_short=True)
    if state["phase"] == "break":
        return end_break(state, cut_short=True)
    return state, "idle"


def toggle(state):
    if state["phase"] == "focus":
        return end_focus(state, cut_short=True)
    return start(state)


def tick(state):
    """Apply the transition that is due, if one is. Safe to run any time."""
    if state["phase"] == "idle" or time.time() < state["ends"]:
        return state, None
    if state["phase"] == "focus":
        return end_focus(state, cut_short=False)
    return end_break(state, cut_short=False)


def seen(state):
    """Elias has read Slack himself: the next brief starts from now."""
    state["last_brief"] = time.time()
    write_state(state)
    return state, "next brief starts from now"


# -- the break brief ----------------------------------------------------------


def brief_prompt(since, settings):
    with open(BRIEF_TEMPLATE, encoding="utf-8") as handle:
        template = handle.read()
    now = time.time()
    fill = {
        "user": settings["slack_user"],
        "since": iso(since),
        "since_ts": str(int(since)),
        "threads_since_ts": str(int(now - 14 * 86400)),
        "now": iso(now),
    }
    for key, value in fill.items():
        template = template.replace("{{" + key + "}}", value)
    return template


def ask_claude(prompt, settings):
    """A headless session with only the Slack tools. Returns (verdict, raw
    result) or (None, error text)."""
    command = [
        "claude", "-p", "--model", settings["model"], "--output-format", "json",
        "--tools", "", "--allowedTools", ",".join(SLACK_TOOLS), "--permission-mode", "dontAsk",
        "--json-schema", json.dumps(VERDICT_SCHEMA),
        "--max-budget-usd", str(settings["max_budget_usd"]), "--no-session-persistence",
    ]
    # Slack comes from the plugin alone. With the claude.ai connectors on,
    # Claude Code's dedup can drop the plugin as the connector's duplicate
    # and the connector as the plugin's, leaving the session without Slack.
    env = {**os.environ, "ENABLE_CLAUDEAI_MCP_SERVERS": "false"}
    try:
        result = subprocess.run(command, input=prompt, capture_output=True, text=True, env=env,
                                timeout=settings["timeout_seconds"], cwd=os.path.expanduser("~"))
    except subprocess.TimeoutExpired:
        return None, f"timed out after {settings['timeout_seconds']}s"
    except OSError as error:
        return None, str(error)
    try:
        output = json.loads(result.stdout)
    except ValueError:
        return None, (result.stderr or result.stdout or "no output")[-500:]
    if output.get("is_error"):
        return None, "; ".join(output.get("errors") or [output.get("subtype") or "error"])
    verdict = output.get("structured_output")
    if not isinstance(verdict, dict):
        # Without structured output, the last JSON object in the reply is it.
        found = re.findall(r"\{[^{}]*\}", output.get("result") or "")
        try:
            verdict = json.loads(found[-1]) if found else None
        except ValueError:
            verdict = None
    if not isinstance(verdict, dict) or verdict.get("verdict") not in ("clear", "attention"):
        return None, (output.get("result") or "no verdict")[-500:]
    if verdict.get("error"):
        return None, verdict["error"]
    verdict["cost_usd"] = output.get("total_cost_usd")
    verdict["duration_s"] = round((output.get("duration_ms") or 0) / 1000)
    return verdict, output.get("result") or ""


def ask_claude_twice(prompt, settings):
    """The MCP connectors are sometimes not up when the session starts, and
    the model then finds no Slack tools. One retry covers that."""
    verdict, raw = ask_claude(prompt, settings)
    if verdict is None:
        time.sleep(5)
        verdict, raw = ask_claude(prompt, settings)
    return verdict, raw


def brief(state, hours=None):
    """The break brief: a headless Claude session says whether anyone wrote
    to Elias during the focus with something that can't wait. One line as a
    notification; the items, if any, in his Slack DM. Fails open: when the
    session fails, the notification says so, Elias looks himself, and the
    window stays open for the next brief."""
    settings = config()["brief"]
    started = time.time()
    if hours:
        since = started - hours * 3600
    else:
        since = state.get("last_brief") or state.get("started") or started - 3600
    verdict, raw = ask_claude_twice(brief_prompt(since, settings), settings) if settings["slack_user"] else (None, "no slack_user in config")
    if verdict is None:
        title = "Brief failed, have a look at Slack yourself"
    elif verdict["verdict"] == "clear":
        title = "All is well, enjoy your break!"
    else:
        title = verdict["headline"]
    notify(title, "" if verdict is None or verdict["verdict"] == "clear" else "In your Slack DM")
    if verdict is not None:
        with locked():
            state = read_state()  # the phase may have moved on while the session ran
            state["last_brief"] = started
            write_state(state)
    os.makedirs(BRIEFS, exist_ok=True)
    with open(os.path.join(BRIEFS, datetime.fromtimestamp(started).strftime("%Y-%m-%d %H%M") + ".md"), "w", encoding="utf-8") as handle:
        handle.write(f"# Brief {iso(started)}\n\nSince {iso(since)}.\n\n{title}\n\n## Claude\n\n{raw}\n")
    log({
        "phase": "brief", "started": iso(started), "since": iso(since),
        "duration_s": round(time.time() - started),
        **{key: (verdict or {}).get(key) for key in ("verdict", "headline", "items", "cost_usd")},
        "failed": verdict is None,
    })
    return state, title


# -- display ------------------------------------------------------------------


def remaining(state):
    seconds = max(0, int(state["ends"] - time.time()))
    return f"{seconds // 60:02d}:{seconds % 60:02d}"


def status_line(state):
    every = config()["long_break_every"]
    cycle = f"{state['count']}/{every}" if every > 0 else str(state["count"])
    if state["phase"] == "idle":
        return f"idle, {cycle} focuses done" if state["count"] else "idle"
    ends = datetime.fromtimestamp(state["ends"]).strftime("%H:%M")
    name = "long break" if state.get("long") else state["phase"]
    return f"{name} {remaining(state)} left, ends {ends}, focus {cycle}"


def waybar(state):
    phase = state["phase"]
    if phase == "idle":
        text = f"{ICONS['idle']} {state['count']}" if state["count"] else ICONS["idle"]
    else:
        text = f"{ICONS[phase]} {remaining(state)}"
    return json.dumps({"text": text, "class": phase, "alt": phase, "tooltip": status_line(state)})


def main(argv):
    command = argv[1] if len(argv) > 1 else "status"
    if command == "phase":
        print(read_state()["phase"])
    elif command == "status":
        print(status_line(read_state()))
    elif command == "brief":
        hours = float(argv[2]) if len(argv) > 2 else None
        print(brief(read_state(), hours)[1])
    elif command in ("waybar", "tick", "start", "stop", "skip", "toggle", "seen"):
        with locked():
            state = read_state()
            if command == "waybar":
                state, _ = tick(state)
                print(waybar(state))
            elif command == "tick":
                tick(state)
            elif command == "start":
                minutes = int(argv[2]) if len(argv) > 2 else None
                print(start(state, minutes)[1])
            else:
                print({"stop": stop, "skip": skip, "toggle": toggle, "seen": seen}[command](state)[1])
    else:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
