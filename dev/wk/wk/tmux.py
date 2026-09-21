"""Thin tmux helpers.

$WK_TMUX_SOCKET names a private server (`tmux -L`), which the tests use so
they can never touch the live one.
"""

import os
import subprocess


def _tmux(*args):
    command = ["tmux"]
    if os.environ.get("WK_TMUX_SOCKET"):
        command += ["-L", os.environ["WK_TMUX_SOCKET"]]
    try:
        result = subprocess.run(
            command + list(args),
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        return None
    return result.stdout.rstrip("\n") if result.returncode == 0 else None


def window_option(target, option):
    """A window's user option (@task, @issue, …), None when unset."""
    return _tmux("display-message", "-p", "-t", target, f"#{{{option}}}") or None


def pane_path(target):
    return _tmux("display-message", "-p", "-t", target, "#{pane_current_path}") or None


def current_task():
    """The task the window around this process was opened for. Inherited
    through $TMUX_PANE, so it holds for hooks and for Claude's children."""
    pane = os.environ.get("TMUX_PANE")
    if not pane or not (os.environ.get("TMUX") or os.environ.get("WK_TMUX_SOCKET")):
        return None
    return window_option(pane, "@task")


def set_window_options(target, options):
    for name, value in options.items():
        _tmux("set-option", "-w", "-t", target, name, value or "")


def rename_window(target, name):
    _tmux("rename-window", "-t", target, name)


def display(message):
    _tmux("display-message", message)


POPUP_PREFIX = "_popup_"


def run(*args):
    """Run a tmux command; its output, or None when it failed."""
    return _tmux(*args)


def windows():
    """Every window on the server, popups excluded."""
    fields = "#{window_id}\t#{session_name}\t#{@task}\t#{@worktree}"
    rows = []
    for line in (_tmux("list-windows", "-a", "-F", fields) or "").splitlines():
        window, session, task, worktree = (line.split("\t") + ["", "", ""])[:4]
        if not session.startswith(POPUP_PREFIX):
            rows.append({"id": window, "session": session, "task": task, "worktree": worktree})
    return rows


def has_session(name):
    return _tmux("has-session", "-t", f"={name}") is not None


def new_session(name, directory):
    _tmux("new-session", "-d", "-s", name, "-c", directory)


def new_window(session, directory, name, command=None):
    """Create a window without switching to it; returns its id."""
    args = ["new-window", "-d", "-t", f"={session}:", "-c", directory, "-n", name, "-P", "-F", "#{window_id}"]
    return _tmux(*(args + ([command] if command else [])))


def clients():
    fields = "#{client_name}\t#{client_pid}\t#{client_session}\t#{client_activity}"
    rows = []
    for line in (_tmux("list-clients", "-F", fields) or "").splitlines():
        name, pid, session, activity = (line.split("\t") + ["", "", ""])[:4]
        rows.append({"name": name, "pid": int(pid or 0), "session": session, "activity": int(activity or 0)})
    return rows


def current_session():
    pane = os.environ.get("TMUX_PANE")
    if not pane or not os.environ.get("TMUX"):
        return None
    return _tmux("display-message", "-p", "-t", pane, "#{session_name}")
