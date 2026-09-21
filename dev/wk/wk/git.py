"""Thin git helpers. All local, all tolerant of "not a repository"."""

import subprocess


def _git(directory, *args):
    try:
        result = subprocess.run(
            ["git", "-C", directory, *args],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
        )
    except (FileNotFoundError, NotADirectoryError):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def branch(directory):
    """The checked-out branch, None when detached or not a repository."""
    return _git(directory, "symbolic-ref", "--quiet", "--short", "HEAD") or None


def toplevel(directory):
    return _git(directory, "rev-parse", "--show-toplevel") or None


def is_repo(directory):
    return toplevel(directory) is not None
