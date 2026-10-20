"""Bring the task-tied windows back after a reboot.

`wk snapshot` records every tmux window tied to a task: the tmux session it
sits in, its name, the task, its directory and the Claude session live in
it. `wk resume` reads that back and recreates each window, one pane with the
Claude session resumed in it; tasks closed in the meantime are skipped, and
so are windows already open. Other panes, and windows tied to no task, are
not part of it: this resumes the work, it is not a session manager.

The snapshot is taken on demand and written twice: as JSON for `wk resume`,
and as Markdown next to it with one command per window, to resume by hand
should the command fail.
"""

import datetime
import json
import os
import shlex

from . import state, tmux, workspace
from .config import xdg
from .errors import NotFound
from .tasks import is_open


def path(extension="json"):
    return os.path.join(xdg("state"), f"snapshot.{extension}")


def take(tasks):
    """Every window tied to a task, in tmux's order, with the Claude session
    running in it. The agent files say which pane each session runs in; a
    session that adopted a task other than the window's still counts as the
    window's session, and is noted as such."""
    by_pane = {}
    for session_id, agent in state.agents().items():
        pid = agent.get("pid")
        if pid and os.path.isdir("/proc") and not os.path.exists(f"/proc/{pid}"):
            continue  # a crash left the file behind
        if agent.get("pane"):
            by_pane[agent["pane"]] = (session_id, agent)
    windows = []
    for window in tmux.windows():
        if not window["task"]:
            continue
        task = tasks.get(window["task"])
        if not task:
            continue
        panes = tmux.panes(window["id"])
        live = [(pane, *by_pane[pane["id"]]) for pane in panes if pane["id"] in by_pane]
        # The session that works on the window's task first; else whichever.
        live.sort(key=lambda found: found[2].get("uuid") != task["uuid"])
        claude_pane, session_id, agent = live[0] if live else (None, None, None)
        directory = window["worktree"] or (claude_pane or (panes[0] if panes else {})).get("path") or ""
        entry = {
            "session": window["session"],
            "index": window["index"],
            "name": window["name"],
            "task": task["uuid"],
            "id": task.get("id"),
            "description": task.get("description", ""),
            "issue": task.get("issue") or "",
            "directory": directory,
            "claude": session_id,
            "others": [other for _, other, _ in live[1:]],
        }
        if agent and agent.get("uuid") and agent["uuid"] != task["uuid"]:
            entry["claude_task"] = agent["uuid"]
        if not session_id and task.get("session"):
            entry["last"] = task["session"]  # not running, but the task's last one
        windows.append(entry)
    return windows


def write(config, windows, taken=None):
    """Both files; returns their paths."""
    taken = taken or datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    snapshot = {"taken": taken, "launcher": workspace.claude_launcher(config), "windows": windows}
    os.makedirs(xdg("state"), exist_ok=True)
    with open(path("json"), "w", encoding="utf-8") as handle:
        json.dump(snapshot, handle, indent=2, ensure_ascii=False)
        handle.write("\n")
    with open(path("md"), "w", encoding="utf-8") as handle:
        handle.write(markdown(snapshot))
    return path("json"), path("md")


def read(file=None):
    try:
        with open(file or path("json"), encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        raise NotFound(f"no snapshot at {file or path('json')}: take one with `wk snapshot`") from None
    except ValueError as err:
        raise NotFound(f"unreadable snapshot {file or path('json')}: {err}") from None


def markdown(snapshot):
    """The snapshot as a page: per tmux session, each window with the command
    that brings it back by hand."""
    launcher = snapshot.get("launcher") or ["claude"]
    lines = [
        "# wk snapshot",
        "",
        f"Taken {snapshot['taken']}. The task-tied tmux windows at that moment, and how to",
        "bring each one back by hand: a window in the tmux session named, in that",
        "directory, running the command. `wk resume` does the same.",
    ]
    if not snapshot["windows"]:
        lines += ["", "No window was tied to a task."]
    current = None
    for entry in snapshot["windows"]:
        if entry["session"] != current:
            current = entry["session"]
            lines += ["", f"## tmux session `{current}`"]
        heading = f"{entry['index']}. {entry['name']}"
        if entry["issue"] and entry["issue"] != entry["name"]:
            heading += f" ({entry['issue']})"
        lines += ["", f"### {heading}", "", f"{entry['description']}  "]
        task = f"task {entry['id']}" if entry.get("id") else "task"
        lines.append(f"{task} `{entry['task']}`  ")
        if entry["claude"]:
            command = shlex.join(launcher + ["--resume", entry["claude"]])
            lines.append(f"`cd {shlex.quote(entry['directory'])} && {command}`")
            if entry.get("claude_task"):
                lines.append(f"(that session had adopted task `{entry['claude_task']}`)")
        else:
            lines.append(f"`cd {shlex.quote(entry['directory'])}`, no Claude session was running")
            if entry.get("last"):
                command = shlex.join(launcher + ["--resume", entry["last"]])
                lines.append(f"(the task's last one: `{command}`)")
        for other in entry.get("others", []):
            command = shlex.join(launcher + ["--resume", other])
            lines.append(f"also in the window: `{command}`")
    return "\n".join(lines) + "\n"


def restore(config, tasks, snapshot, dry_run=False):
    """Recreate the snapshot's windows, in its order. One result per entry:
    its outcome (opened, would open, skipped) and why."""
    launcher = workspace.claude_launcher(config)
    open_tasks = {window["task"] for window in tmux.windows() if window["task"]}
    results = []
    for entry in snapshot["windows"]:
        result = {key: entry.get(key) for key in ("session", "name", "task", "id", "description", "issue")}
        task = tasks.get(entry["task"])
        if not task or not is_open(task):
            result.update(outcome="skipped", why="task closed" if task else "task gone")
        elif task["uuid"] in open_tasks:
            result.update(outcome="skipped", why="already open")
        else:
            session_id = entry.get("claude")
            resumable = bool(session_id and state.resumable(session_id))
            command = shlex.join(launcher + ["--resume", session_id]) if resumable else None
            result["resumed"] = resumable
            if session_id and not resumable:
                result["why"] = f"Claude has no transcript for {session_id}"
            if dry_run:
                result["outcome"] = "would open"
            else:
                directory = entry.get("directory") if os.path.isdir(entry.get("directory") or "") else None
                opened = workspace.ensure_window(
                    config,
                    tasks,
                    task,
                    directory or os.getcwd(),
                    command=command,
                    plain_dir=directory,
                    in_session=entry["session"],
                )
                if opened.created_window and entry.get("name") and entry["name"] != window_name_of(opened.window):
                    tmux.rename_window(opened.window, entry["name"])
                open_tasks.add(task["uuid"])
                result.update(outcome="opened", window=opened.window, directory=opened.directory)
        results.append(result)
    return results


def window_name_of(window):
    return tmux.window_option(window, "window_name") or ""


def describe(results):
    lines = []
    for result in results:
        label = result.get("issue") or result.get("name") or result["task"][:8]
        where = f"{result['session']}:{label}"
        if result["outcome"] == "skipped":
            lines.append(f"{where}  skipped, {result['why']}")
        elif result["outcome"] == "would open":
            how = "resume Claude" if result["resumed"] else "no Claude"
            lines.append(f"{where}  would open, {how}" + (f" ({result['why']})" if result.get("why") else ""))
        else:
            how = "Claude resumed" if result["resumed"] else "no Claude"
            lines.append(f"{where}  opened, {how}" + (f" ({result['why']})" if result.get("why") else ""))
    return lines
