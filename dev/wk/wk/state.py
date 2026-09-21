"""One state per task, topmost wins:

    input > working > idle > window > checkout > resume > nothing

(a worktree exists; a Claude session can be resumed. Not "worktree" and
"session": taskwarrior reads a value that is also an attribute's name as a
reference to that attribute.)

It says what "open in tmux" will find, and where attention is needed. The
facts live outside taskwarrior (agent files written by Claude's hooks, tmux
itself, the filesystem); the task's `state` is derived from them and written
only when it changes, since every `task modify` runs hooks and grows the
operation log. `state_flag` mirrors it as a glyph, for a narrow column.
"""

import json
import os

from . import tmux
from .config import xdg
from .tasks import is_open

AGENT_ORDER = ("input", "working", "idle")
# Nerd Font glyphs, written as escapes: private-use characters do not survive
# every editor and pipe. bell, run, sleep, window, git branch, history.
FLAGS = {
    "input": "\U000f009a",
    "working": "\U000f046e",
    "idle": "\U000f04b2",
    "window": "\uf2d0",
    "checkout": "\uf418",
    "resume": "\U000f0453",
    "": "",
}


def agents_dir():
    return os.path.join(xdg("state"), "agents")


def read_agent(session_id):
    try:
        with open(os.path.join(agents_dir(), f"{session_id}.json"), encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, ValueError):
        return None


def write_agent(session_id, agent):
    os.makedirs(agents_dir(), exist_ok=True)
    path = os.path.join(agents_dir(), f"{session_id}.json")
    temporary = f"{path}.tmp.{os.getpid()}"
    with open(temporary, "w", encoding="utf-8") as handle:
        json.dump(agent, handle)
    os.replace(temporary, path)


def remove_agent(session_id):
    try:
        os.remove(os.path.join(agents_dir(), f"{session_id}.json"))
    except OSError:
        pass


def agents():
    found = {}
    try:
        names = os.listdir(agents_dir())
    except OSError:
        return found
    for name in names:
        if name.endswith(".json"):
            agent = read_agent(name[:-5])
            if agent:
                found[name[:-5]] = agent
    return found


def reap():
    """Forget agents whose Claude process is gone: a crash or a killed
    terminal never sends SessionEnd."""
    for session_id, agent in agents().items():
        pid = agent.get("pid")
        if pid and not os.path.exists(f"/proc/{pid}") and os.path.isdir("/proc"):
            remove_agent(session_id)


def compute(task, agent_statuses, window_tasks):
    statuses = agent_statuses.get(task["uuid"], ())
    for status in AGENT_ORDER:
        if status in statuses:
            return status
    if task["uuid"] in window_tasks:
        return "window"
    if task.get("worktree") and os.path.isdir(task["worktree"]):
        return "checkout"
    if task.get("session"):
        return "resume"
    return ""


def refresh(tasks, config=None, only=None):
    """Recompute and write the state of open tasks (of `only`, a uuid, when
    just one is known to have changed). Returns the uuids written."""
    flags = {**FLAGS, **((config.data.get("state", {}).get("flags", {})) if config else {})}
    statuses = {}
    for agent in agents().values():
        statuses.setdefault(agent.get("uuid"), set()).add(agent.get("status"))
    window_tasks = {window["task"] for window in tmux.windows() if window["task"]}
    written = []
    for task in tasks.all():
        if only and task["uuid"] != only:
            continue
        state = compute(task, statuses, window_tasks) if is_open(task) else ""
        if tasks.modify(task, {"state": state, "state_flag": flags.get(state, "")}):
            written.append(task["uuid"])
    return written
