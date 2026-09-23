"""The taskwarrior adapter: the only module that runs `task`.

Reads are one full export per process, indexed here. Filters are avoided on
purpose: `issue:KEY` is a prefix match in taskwarrior 3 (TEAM-85 also finds
TEAM-852), and an export of everything costs a few milliseconds.

Writes go through modify(), which drops anything that would not change the
task: every `task modify` runs hooks and grows the operation log.
"""

import json
import os
import subprocess

from .errors import WkError
from .locator import is_uuid

OPEN = ("pending", "waiting")

# rc.gc=0 keeps working-set ids stable: a background caller must never
# renumber the tasks under a TUI that is showing them.
BASE = ["task", "rc.context=", "rc.verbose=nothing", "rc.gc=0", "rc.confirmation=off"]


def is_open(task):
    return task.get("status") in OPEN


def _preferred(candidates):
    """Open tasks before closed ones, then the oldest."""
    ranked = sorted(candidates, key=lambda t: (0 if is_open(t) else 1, t.get("entry", "")))
    return ranked[0] if ranked else None


class Tasks:
    def __init__(self, run=subprocess.run):
        self._run = run
        self._all = None

    def _task(self, args, check=True):
        try:
            result = self._run(BASE + args, capture_output=True, text=True, stdin=subprocess.DEVNULL)
        except FileNotFoundError as err:
            raise WkError("taskwarrior (`task`) is not installed") from err
        if check and result.returncode != 0:
            message = (result.stderr or result.stdout).strip()
            raise WkError(f"task {' '.join(args)}: {message}")
        return result

    def all(self):
        if self._all is None:
            output = self._task(["export"]).stdout
            self._all = json.loads(output) if output.strip() else []
        return self._all

    def invalidate(self):
        self._all = None

    # -- lookups ----------------------------------------------------------

    def get(self, ref):
        """By uuid, or by working-set id."""
        ref = str(ref)
        if is_uuid(ref):
            return next((t for t in self.all() if t["uuid"] == ref.lower()), None)
        if ref.isdigit() and int(ref) > 0:
            return next((t for t in self.all() if t.get("id") == int(ref)), None)
        return None

    def by_field(self, field, value):
        return _preferred([t for t in self.all() if t.get(field) == value])

    def by_issue(self, key):
        return self.by_field("issue", key.upper())

    def by_branch(self, branch):
        return self.by_field("branch", branch)

    def by_worktree(self, path):
        """The task whose worktree is `path` or contains it; deepest wins."""
        path = os.path.realpath(path)
        matches = []
        for task in self.all():
            worktree = task.get("worktree")
            if not worktree:
                continue
            worktree = os.path.realpath(worktree)
            if path == worktree or path.startswith(worktree + os.sep):
                matches.append((len(worktree), task))
        if not matches:
            return None
        deepest = max(length for length, _ in matches)
        return _preferred([task for length, task in matches if length == deepest])

    def by_pr(self, number, repo=None):
        """Matches the legacy pr_number too ("#10307", "10307.000000")."""
        number = str(number).lstrip("#")
        matches = []
        for task in self.all():
            legacy = str(task.get("pr_number", "")).split(".")[0].lstrip("#")
            listed = [p.strip().lstrip("#") for p in str(task.get("prs", "")).split(",")]
            if number != legacy and number not in listed:
                continue
            task_repo = task.get("repo") or task.get("pr_repo")
            if repo and task_repo and repo.lower() != task_repo.lower():
                continue
            matches.append(task)
        return _preferred(matches)

    # -- writes -----------------------------------------------------------

    def add(self, description, attrs=None, tags=()):
        """Create a task and return it. Attributes precede `--` so taskwarrior
        parses them; the description after it is taken verbatim, which keeps a
        title containing a colon or a plus sign from being read as metadata."""
        args = ["rc.verbose=new-uuid", "add"]
        args += [f"{key}:{value}" for key, value in (attrs or {}).items() if value]
        args += [f"+{tag}" for tag in tags]
        args += ["--", description]
        output = self._task(args).stdout
        uuid = next((word.rstrip(".") for word in output.split() if is_uuid(word.rstrip("."))), None)
        if not uuid:
            raise WkError(f"task add did not report a uuid: {output.strip()}")
        self.invalidate()
        return self.get(uuid)

    def modify(self, task, changes=None, add_tags=(), remove_tags=()):
        """Apply only what differs. `None` or "" clears an attribute. Returns
        whether anything was written."""
        args = []
        for key, value in (changes or {}).items():
            value = "" if value is None else str(value)
            if str(task.get(key, "")) != value:
                args.append(f"{key}:{value}")
        tags = set(task.get("tags", []))
        args += [f"+{tag}" for tag in add_tags if tag not in tags]
        args += [f"-{tag}" for tag in remove_tags if tag in tags]
        if not args:
            return False
        self._task([task["uuid"], "modify"] + args)
        self.invalidate()
        return True

    def start(self, task):
        if not task.get("start"):
            self._task([task["uuid"], "start"])
            self.invalidate()

    def done(self, task):
        self._task([task["uuid"], "done"])
        self.invalidate()

    def delete(self, task):
        self._task([task["uuid"], "delete"])
        self.invalidate()

    def revive(self, task):
        """Reopen a completed task."""
        self._task([task["uuid"], "modify", "status:pending", "end:"])
        self.invalidate()
