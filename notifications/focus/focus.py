#!/usr/bin/env python3
"""focus: a pomodoro timer that holds notifications while you work.

Focus turns swaync's do-not-disturb on, so whatever arrives collects in the
control center instead of popping up; the break turns it off, opens the
control center and chimes, so the held items come up together. The break
starts on its own when focus ends. The next focus waits for you: hyper+S or a
click on the waybar module. Every fourth break is a long one.

    focus toggle          idle or break -> start focus; focus -> break now
    focus start [MINUTES] start focus (a break in progress ends now)
    focus stop            back to idle from any phase, dnd off, cycle reset
    focus skip            end the current phase now
    focus status          one line for a terminal
    focus phase           print focus, break or idle (for other scripts)
    focus waybar          JSON for the waybar module; also applies a due
                          transition, as a fallback for the timer
    focus tick            apply a due transition (run by a transient systemd
                          timer at the end of each phase)

Other scripts read the phase: claude_notification keeps quiet during focus
unless its pane is the one being looked at, and tmux (`@focus`, set here)
hides the bell highlight until the break.

Files, under $XDG_STATE_HOME/focus: state.json, and log.jsonl with one line
per finished phase (planned and actual length, whether it was cut short), for
tuning the lengths in ~/.config/focus/config.toml.
"""

import json
import os
import subprocess
import sys
import time
import tomllib
from datetime import datetime

DEFAULTS = {"focus": 25, "break": 5, "long_break": 15, "long_break_every": 4}
SOUNDS = "/usr/share/sounds/freedesktop/stereo"
CHIME = {"break": f"{SOUNDS}/complete.oga", "idle": f"{SOUNDS}/bell.oga"}
TIMER_UNIT = "focus-tick"
WAYBAR_SIGNAL = 9  # custom/focus listens on RTMIN+9
ICONS = {"focus": "\U000f051b", "break": "\U000f0176", "idle": "\U000f051b"}  # timer, coffee
IDLE = {"phase": "idle", "count": 0}


def xdg(kind, default):
    return os.environ.get(f"XDG_{kind}_HOME") or os.path.expanduser(default)


STATE_DIR = os.path.join(xdg("STATE", "~/.local/state"), "focus")
STATE = os.path.join(STATE_DIR, "state.json")
LOG = os.path.join(STATE_DIR, "log.jsonl")
CONFIG = os.path.join(xdg("CONFIG", "~/.config"), "focus", "config.toml")


# -- plumbing -----------------------------------------------------------------


def config():
    try:
        with open(CONFIG, "rb") as handle:
            return {**DEFAULTS, **tomllib.load(handle)}
    except (OSError, tomllib.TOMLDecodeError):
        return dict(DEFAULTS)


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


def log(state, ended, cut_short):
    """One line per finished phase, the data for tuning the lengths."""
    os.makedirs(STATE_DIR, exist_ok=True)
    line = {
        "phase": state["phase"],
        "started": datetime.fromtimestamp(state["started"]).isoformat(timespec="seconds"),
        "ended": datetime.fromtimestamp(ended).isoformat(timespec="seconds"),
        "planned_min": state["planned"],
        "actual_min": round((ended - state["started"]) / 60, 1),
        "cut_short": cut_short,
        "n": state["count"],
        "long": state.get("long", False),
    }
    with open(LOG, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(line) + "\n")


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
    if os.path.exists(CHIME[phase]):
        try:
            subprocess.Popen(["paplay", CHIME[phase]], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except OSError:
            pass


def refresh_waybar():
    run("pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "-x", "waybar")


def schedule_tick(seconds):
    """A transient timer fires `focus tick` when the phase ends; the waybar
    poll applies the transition too, in case the timer doesn't."""
    cancel_tick()
    run(
        "systemd-run", "--user", "--quiet", "--collect",
        f"--unit={TIMER_UNIT}", f"--on-active={max(1, int(seconds))}",
        "--timer-property=AccuracySec=1s",
        sys.executable, os.path.abspath(__file__), "tick",
    )


def cancel_tick():
    run("systemctl", "--user", "stop", "--quiet", f"{TIMER_UNIT}.timer", f"{TIMER_UNIT}.service")


# -- transitions --------------------------------------------------------------


def start(state, minutes=None):
    now = time.time()
    if state["phase"] == "focus":
        return state, "already focusing"
    if state["phase"] == "break":
        log(state, now, cut_short=True)
        if state.get("long"):
            state["count"] = 0
    minutes = minutes or config()["focus"]
    state = {"phase": "focus", "started": now, "ends": now + minutes * 60, "planned": minutes, "count": state["count"]}
    write_state(state)
    dnd(True)
    tmux_focus(True)
    schedule_tick(minutes * 60)
    refresh_waybar()
    return state, f"focus for {minutes} min"


def end_focus(state, cut_short):
    """Focus ends: the break starts on its own, and the held notifications
    come up together."""
    now = time.time()
    log(state, now, cut_short)
    settings = config()
    count = state["count"] + 1
    long = settings["long_break_every"] > 0 and count % settings["long_break_every"] == 0
    minutes = settings["long_break"] if long else settings["break"]
    state = {"phase": "break", "started": now, "ends": now + minutes * 60, "planned": minutes, "count": count, "long": long}
    write_state(state)
    dnd(False)
    tmux_focus(False)
    chime("break")
    run("swaync-client", "-op", "-sw")
    schedule_tick(minutes * 60)
    refresh_waybar()
    return state, f"{'long ' if long else ''}break for {minutes} min"


def end_break(state, cut_short):
    """The break ends with a nudge; the next focus waits for the hotkey."""
    now = time.time()
    log(state, now, cut_short)
    state = {"phase": "idle", "count": 0 if state.get("long") else state["count"]}
    write_state(state)
    cancel_tick()
    if not cut_short:
        chime("idle")
        run("notify-send", "-a", "focus", "-u", "normal", "Break over", "hyper+S starts the next focus")
    refresh_waybar()
    return state, "idle"


def stop(state):
    now = time.time()
    if state["phase"] != "idle":
        log(state, now, cut_short=True)
    state = dict(IDLE)
    write_state(state)
    cancel_tick()
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
    state = read_state()
    if command == "waybar":
        state, _ = tick(state)
        print(waybar(state))
    elif command == "phase":
        print(state["phase"])
    elif command == "status":
        print(status_line(state))
    elif command == "tick":
        tick(state)
    elif command == "start":
        minutes = int(argv[2]) if len(argv) > 2 else None
        print(start(state, minutes)[1])
    elif command in ("stop", "skip", "toggle"):
        print({"stop": stop, "skip": skip, "toggle": toggle}[command](state)[1])
    else:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
