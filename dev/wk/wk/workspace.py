"""Open a task in tmux: jump to its window; else create the window from its
worktree; else the worktree from its branch; else the branch.

A tmux session per repository; the task's repo decides, and the session is
created if missing. A task with no repository (a plain to-do) just gets a
window. What is found or created is recorded on the task (`branch`,
`worktree`, `repo`) and on the window (@task, @worktree, @issue, @desc), which
is how a session started there later finds its task.
"""

import os
import re
from dataclasses import dataclass

from . import git, tmux
from .errors import WkError
from .locator import issue_key_in


@dataclass
class Opened:
    window: str
    session: str
    directory: str
    created_window: bool = False
    created_worktree: bool = False


def branch_prefix(config):
    return config.data["defaults"].get("branch_prefix") or f"{os.environ.get('USER', 'me')}/"


def _slug(text, limit=40):
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")[:limit].strip("-")


def repo_path(config, task, cwd):
    """The main checkout of the task's repository, or None for a task that
    has none. Only work that lives in code gets one inferred."""
    name = task.get("repo")
    here = git.main_worktree(cwd) if git.is_repo(cwd) else None
    if name:
        configured = config.data["repos"].get(name, {}).get("path")
        if configured and os.path.isdir(os.path.expanduser(configured)):
            return name, git.main_worktree(os.path.expanduser(configured))
        if here and (git.slug(here) or "").lower() == name.lower():
            return name, here
        raise WkError(f'no checkout known for {name}: set repos."{name}".path in {config.path}')
    if not (task.get("issue") or task.get("branch")):
        return None, None
    root = (task.get("project") or "").split(".")[0]
    candidates = [
        (repo, os.path.expanduser(entry["path"]))
        for repo, entry in config.data["repos"].items()
        if entry.get("project") == root and entry.get("path") and os.path.isdir(os.path.expanduser(entry["path"]))
    ]
    if len(candidates) == 1:
        return candidates[0][0], git.main_worktree(candidates[0][1])
    if here:
        return git.slug(here), here
    return None, None


def branch_for(config, task, fetch_issue=None):
    if task.get("branch"):
        return task["branch"]
    key = task.get("issue")
    if key:
        # The tracker suggests a branch name; asking is worth a round trip,
        # but being offline must not stop the work.
        try:
            if fetch_issue is None:
                from .trackers.linear import fetch_issue
            suggested = fetch_issue(key).get("branch")
            if suggested:
                return suggested
        except WkError:
            pass
        return f"{branch_prefix(config)}{key.lower()}-{_slug(task.get('description', ''))}".rstrip("-")
    return f"{branch_prefix(config)}{_slug(task.get('description', '')) or task['uuid'][:8]}"


def worktree_dir(main, branch):
    """<main>/.worktrees/<lowercase issue key>, a deterministic path per
    issue; else the branch minus its author prefix."""
    key = issue_key_in(branch)
    name = key.lower() if key else branch.split("/", 1)[-1].replace("/", "-")
    return os.path.join(main, ".worktrees", name)


def window_name(task):
    if task.get("issue"):
        return task["issue"]
    if task.get("prs"):
        return str(task["prs"]).split(",")[0]
    return _slug(task.get("description", ""), 24) or task["uuid"][:8]


def ensure_window(config, tasks, task, cwd, branch=None, command=None, fetch_issue=None, plain_dir=None):
    """Find or create the task's window, without switching to it. `plain_dir`
    is where a task without a repository of its own gets its window."""
    for window in tmux.windows():
        if window["task"] == task["uuid"]:
            return Opened(window["id"], window["session"], window["worktree"] or cwd)

    # Only work that lives on a branch gets a checkout; anything else (a plain
    # to-do, untracked tinkering) gets a window where it already is.
    wants_checkout = branch or task.get("issue") or task.get("branch") or task.get("prs")
    repo, main = repo_path(config, task, cwd) if wants_checkout else (None, None)
    if branch and not main:
        raise WkError("a branch needs a repository: run this from inside one, or set `repo` on the task")
    created_worktree = False
    if main:
        branch = branch or branch_for(config, task, fetch_issue)
        directory = task.get("worktree") if os.path.isdir(task.get("worktree") or "") else None
        directory = directory or git.worktree_for_branch(main, branch)
        if not directory:
            directory = worktree_dir(main, branch)
            if not os.path.isdir(directory):
                git.add_worktree(main, directory, branch)
                created_worktree = True
        tasks.modify(task, {"branch": branch, "worktree": directory, "repo": repo})
        session = config.data["repos"].get(repo or "", {}).get("session") or os.path.basename(main)
    elif plain_dir and git.is_repo(plain_dir):
        # Untracked work in a repository: its main checkout, its session, and
        # no worktree or branch unless asked for.
        directory = plain_dir
        slug = git.slug(plain_dir) or ""
        session = config.data["repos"].get(slug, {}).get("session") or os.path.basename(git.main_worktree(plain_dir))
        tasks.modify(task, {"repo": slug})
    else:
        directory = os.path.expanduser(plain_dir or config.data["defaults"].get("dir", "~"))
        session = config.data["defaults"].get("session") or "main"
    session = re.sub(r"[.:]", "-", session)

    # A window made for this checkout by other means (prefix W, or a parent's
    # agent working on this sub-issue's branch) is where the work is. It is
    # only claimed when nobody else has.
    for window in tmux.windows():
        if main and window["worktree"] == directory:
            if not window["task"]:
                _annotate(window["id"], task, directory)
            return Opened(window["id"], window["session"], directory, created_worktree=created_worktree)

    if not tmux.has_session(session):
        tmux.new_session(session, main or directory)
    window = tmux.new_window(session, directory, window_name(task), command)
    if not window:
        raise WkError(f"could not create a tmux window in session {session}")
    _annotate(window, task, directory if main else "")
    from . import state

    state.refresh(tasks, config, only=task["uuid"])
    return Opened(window, session, directory, created_window=True, created_worktree=created_worktree)


def _annotate(window, task, worktree):
    label = task.get("issue") or str(task.get("prs") or "").split(",")[0]
    options = {"@task": task["uuid"], "@issue": label, "@desc": task.get("description", "")}
    if worktree:
        options["@worktree"] = worktree
    tmux.set_window_options(window, options)


def go(opened):
    """Bring the window in front of the person. Where "in front" is depends on
    where this runs: an ordinary pane, the tasks popup (a nested client: move
    the outer one, then close the popup), or a terminal outside tmux (move an
    attached client, then focus its terminal window)."""
    current = tmux.current_session()
    if current and not current.startswith(tmux.POPUP_PREFIX):
        tmux.run("switch-client", "-t", opened.window)
        return
    client = _outer_client(opened.session)
    if not client:
        raise WkError("no tmux client is attached to switch to the window")
    tmux.run("switch-client", "-c", client["name"], "-t", opened.window)
    if current:
        tmux.run("detach-client", "-s", f"={current}")
    else:
        from . import platform

        platform.focus_terminal(client["pid"])


def _outer_client(session):
    clients = [c for c in tmux.clients() if not c["session"].startswith(tmux.POPUP_PREFIX)]
    if not clients:
        return None
    # The popup scripts record which client a popup opened on; typing inside
    # a popup does not count as activity of the client around it.
    recorded = tmux.run("show-options", "-gqv", "@popup_outer_client")
    if tmux.current_session():
        for client in clients:
            if client["name"] == recorded:
                return client
    on_session = [c for c in clients if c["session"] == session]
    return max(on_session or clients, key=lambda c: c["activity"])
