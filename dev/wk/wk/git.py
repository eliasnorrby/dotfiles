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


def _run(directory, *args):
    """Like _git, for commands whose failure is the caller's business."""
    return subprocess.run(["git", "-C", directory, *args], capture_output=True, text=True, stdin=subprocess.DEVNULL)


def main_worktree(directory):
    """The repository's main checkout (git lists it first). Anchoring there
    keeps worktrees from nesting when this runs from inside one."""
    listing = _git(directory, "worktree", "list", "--porcelain") or ""
    first = next((line for line in listing.splitlines() if line.startswith("worktree ")), None)
    return first.split(" ", 1)[1] if first else None


def worktree_for_branch(directory, branch):
    """Where `branch` is checked out already, if anywhere."""
    path = None
    for line in (_git(directory, "worktree", "list", "--porcelain") or "").splitlines():
        if line.startswith("worktree "):
            path = line.split(" ", 1)[1]
        elif line == f"branch refs/heads/{branch}":
            return path
    return None


def slug(directory):
    """owner/name, from the origin remote."""
    import re

    url = _git(directory, "remote", "get-url", "origin") or ""
    match = re.search(r"[:/]([^/:]+)/([^/]+?)(?:\.git)?/?$", url)
    return f"{match.group(1)}/{match.group(2)}" if match else None


def default_branch(directory):
    """The remote's default branch (origin/main, …) to fork new work from."""
    head = _git(directory, "rev-parse", "--abbrev-ref", "origin/HEAD")
    if head and head != "origin/HEAD":
        return head
    for candidate in ("origin/master", "origin/main", "master", "main"):
        if _git(directory, "rev-parse", "--verify", "--quiet", candidate):
            return candidate
    return None


def add_worktree(repo, path, branch):
    """Create the worktree at `path` for `branch`, choosing the incantation
    by whether the branch exists locally, on the remote, or not at all."""
    from .errors import WkError

    _run(repo, "fetch", "--quiet", "origin")  # best effort: offline is fine
    if _git(repo, "show-ref", "--verify", f"refs/heads/{branch}"):
        result = _run(repo, "worktree", "add", path, branch)
    elif _git(repo, "rev-parse", "--verify", "--quiet", f"origin/{branch}"):
        result = _run(repo, "worktree", "add", path, "--track", "-b", branch, f"origin/{branch}")
    else:
        base = default_branch(repo)
        if not base:
            raise WkError("could not determine a base branch to fork from")
        # --no-track: the branch forks off the default branch but must not
        # adopt it as upstream (git would otherwise auto-track the start point).
        result = _run(repo, "worktree", "add", "--no-track", "-b", branch, path, base)
    if result.returncode != 0:
        raise WkError(f"git worktree add failed: {result.stderr.strip()}")
