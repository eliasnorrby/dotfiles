"""From a locator to a task. Local only: nothing here touches the network.

With no locator the question is "which piece of work is this process part
of?", answered in layers, first hit wins:

1. the tmux window's @task option. Authoritative, because the session was put
   there on purpose; correct even when a parent's agent works on a sub-issue's
   branch.
2. the Claude session: the open task whose `session` is
   $CLAUDE_CODE_SESSION_ID, as `wk adopt` and the SessionStart hook record
   it. Holds outside tmux and in a shared root, where nothing else can tell.
3. the worktree recorded on a task, matched against the directory.
4. the branch: a task that records it, else the issue key it carries.

Layers 3 and 4 only hold for a checkout of the task's own. A shared root (a
project's `dir`, the default directory, home) is where many tasks open, and
its branch is whatever the main checkout is on: being there says nothing
about which task this is.
"""

import os
from dataclasses import dataclass

from . import git, tmux
from .locator import Locator, issue_key_in


@dataclass
class Resolution:
    task: dict | None = None
    how: str | None = None
    # What could be imported when there is no task yet: an issue or a PR.
    reference: Locator | None = None
    branch: str | None = None

    @property
    def issue(self):
        if self.task and self.task.get("issue"):
            return self.task["issue"]
        if self.reference and self.reference.kind == "issue":
            return self.reference.value
        return None


def _from_branch(tasks, branch):
    if not branch:
        return Resolution()
    task = tasks.by_branch(branch)
    if task:
        return Resolution(task, "branch", branch=branch)
    key = issue_key_in(branch)
    if not key:
        return Resolution(branch=branch)
    reference = Locator("issue", key)
    return Resolution(tasks.by_issue(key), "issue", reference, branch)


def shared_roots():
    """(trees, exact): each project's `dir`, whose whole tree is shared, and
    the default directory and home, which are shared only themselves (the
    rest of home is anybody's)."""
    from .config import Config

    try:
        data = Config.load().data
    except Exception:
        return set(), set()

    def real(path):
        return os.path.realpath(os.path.expanduser(path))

    trees = {real(p["dir"]) for p in data["projects"].values() if p.get("dir")}
    exact = {real(data["defaults"].get("dir") or "~"), real("~")}
    return trees, exact


def _from_directory(tasks, directory):
    trees, exact = shared_roots()
    task = tasks.by_worktree(directory, ignore=trees | exact)
    if task:
        return Resolution(task, "worktree", branch=git.branch(directory))
    directory = os.path.realpath(directory)
    if directory in exact or any(directory == t or directory.startswith(t + os.sep) for t in trees):
        return Resolution(branch=git.branch(directory))
    return _from_branch(tasks, git.branch(directory))


def session_task(tasks, session):
    """The open task the Claude session SESSION works on, if it has adopted one."""
    from . import state

    if not session:
        return None
    agent = state.read_agent(session) or {}
    return tasks.by_session(session, current=agent.get("uuid"))


def resolve(tasks, locator=None, cwd=None, session=None):
    """SESSION is the Claude session asking; $CLAUDE_CODE_SESSION_ID when not
    given. Only the "here" question (no locator) consults it."""
    cwd = cwd or os.getcwd()

    if locator is None:
        uuid = tmux.current_task()
        task = tasks.get(uuid) if uuid else None
        if task:
            return Resolution(task, "window", branch=git.branch(cwd))
        task = session_task(tasks, session or os.environ.get("CLAUDE_CODE_SESSION_ID"))
        if task:
            return Resolution(task, "session", branch=git.branch(cwd))
        return _from_directory(tasks, cwd)

    if locator.kind == "task":
        return Resolution(tasks.get(locator.value), "task")
    if locator.kind == "issue":
        return Resolution(tasks.by_issue(locator.value), "issue", locator)
    if locator.kind == "pr":
        return Resolution(tasks.by_pr(locator.value, locator.repo), "pr", locator)
    if locator.kind == "branch":
        return _from_branch(tasks, locator.value)
    if locator.kind == "dir":
        return _from_directory(tasks, locator.value)
    if locator.kind == "window":
        uuid = tmux.window_option(locator.value, "@task")
        task = tasks.get(uuid) if uuid else None
        if task:
            return Resolution(task, "window")
        path = tmux.pane_path(locator.value)
        return _from_directory(tasks, path) if path else Resolution()
    raise ValueError(f"unknown locator kind: {locator.kind}")
