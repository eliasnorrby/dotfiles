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
