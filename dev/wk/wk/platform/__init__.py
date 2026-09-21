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
    result = _quiet(["open" if MACOS else "xdg-open", url])
    if result is None or result.returncode != 0:
        raise WkError(f"could not open {url}")


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
