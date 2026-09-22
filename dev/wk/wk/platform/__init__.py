"""The few things that differ between machines: opening a URL, desktop
notifications, the clipboard. Kept behind this seam so nothing else asks
which OS it is on."""

import subprocess
import sys

from ..errors import WkError

MACOS = sys.platform == "darwin"


def _quiet(command):
    try:
        return subprocess.run(command, capture_output=True, text=True, stdin=subprocess.DEVNULL)
    except FileNotFoundError:
        return None


def open_url(url):
    opener = "open" if MACOS else "xdg-open"
    result = _quiet([opener, url])
    if result is None:
        raise WkError(f"{opener} is not installed; could not open {url}")
    if result.returncode != 0:
        reason = result.stderr.strip() or f"{opener} exited {result.returncode}"
        raise WkError(f"could not open {url}: {reason}")


def notify(title, body, urgency="normal"):
    """Best effort: a missing notifier is not an error."""
    if MACOS:
        _quiet(["terminal-notifier", "-title", title, "-message", body])
    else:
        _quiet(["notify-send", "-u", urgency, "-a", "wk", title, body])


def read_clipboard():
    """Delegated to paste_cmd (shell/clipboard), which knows where the
    clipboard actually is: a pane created inside a mosh session has no Wayland
    connection of its own, so reading one directly fails exactly when working
    remotely."""
    result = _quiet(["paste_cmd"])
    if result is None:
        raise WkError("paste_cmd is not on PATH")
    return result.stdout.strip()


def _parent_pid(pid):
    try:
        with open(f"/proc/{pid}/stat", encoding="utf-8") as handle:
            # The command name is parenthesised and may contain spaces
            # ("tmux: client"); the fields proper start after the last ')'.
            return int(handle.read().rsplit(")", 1)[1].split()[1])
    except (OSError, ValueError, IndexError):
        return 0


def focus_terminal(pid):
    """Focus the desktop window hosting process `pid` (a tmux client). Best
    effort and Hyprland only: a client reached over ssh or mosh has no window
    here, and that is fine."""
    import json

    if MACOS:
        return
    listing = _quiet(["hyprctl", "clients", "-j"])
    if listing is None or listing.returncode != 0:
        return
    try:
        windows = {client["pid"]: client for client in json.loads(listing.stdout)}
    except ValueError:
        return
    while pid > 1 and pid not in windows:
        pid = _parent_pid(pid)
    window = windows.get(pid)
    if not window:
        return
    monitors = _quiet(["hyprctl", "monitors", "-j"])
    try:
        special = [m["specialWorkspace"]["name"] for m in json.loads(monitors.stdout) if m["focused"]]
    except (AttributeError, ValueError, KeyError, TypeError):
        special = []
    # A visible special workspace (where the task list lives) would stay on
    # top of the window being focused, unless that window is on it.
    if special and special[0] and window.get("workspace", {}).get("name") != special[0]:
        _quiet(["hyprctl", "dispatch", "togglespecialworkspace", special[0].removeprefix("special:")])
    _quiet(["hyprctl", "dispatch", "focuswindow", f"address:{window['address']}"])
