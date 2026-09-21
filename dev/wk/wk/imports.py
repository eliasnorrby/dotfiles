"""Create a task from an issue or PR reference.

Importing the same reference twice is a no-op: an open task for it is
returned rather than duplicated, so this is safe to bind to a key and to call
from hooks.

The identifier is kept out of the description and stored in a UDA instead.
"""

import re
from dataclasses import dataclass

from .errors import Unreachable, WkError
from .locator import issue_key_in
from .tasks import is_open


@dataclass
class Imported:
    task: dict
    created: bool
    stub: bool = False


def _title_from_branch(branch, key):
    """A readable stand-in for the title, for when the tracker can't be asked:
    `someone/team-12-fix-the-thing` becomes "fix the thing"."""
    slug = (branch or "").split("/", 1)[-1]
    slug = re.sub(re.escape(key), "", slug, flags=re.I)
    words = re.sub(r"[-_]+", " ", slug).strip()
    return words or key


def import_issue(config, tasks, key, offline=False, branch=None, fetch=None):
    existing = tasks.by_issue(key)
    if existing and is_open(existing):
        return Imported(existing, created=False)

    tracker = config.tracker_for_issue(key)
    if tracker != "linear":
        raise WkError(f"no support for tracker {tracker!r} (issue {key})")
    if fetch is None:
        from .trackers.linear import fetch_issue as fetch

    issue = None
    if not offline:
        try:
            issue = fetch(key)
        except Unreachable:
            # Offline is a state to work in, not an error: create the task
            # from what is known locally and let sync fill in the rest.
            issue = None

    attrs = {"issue": key, "project": config.project_for_issue(key)}
    if branch and issue_key_in(branch) == key:
        attrs["branch"] = branch
    if issue is None:
        task = tasks.add(_title_from_branch(branch, key), attrs, tags=["stub"])
        return Imported(task, created=True, stub=True)

    if not issue.get("title"):
        raise WkError(f"resolved {key} but it has no title")
    parent = tasks.by_issue(issue["parent"]) if issue.get("parent") else None
    if parent:
        attrs["partof"] = parent["uuid"]
    return Imported(tasks.add(issue["title"], attrs), created=True)


def import_pr(config, tasks, number, repo=None, offline=False, cwd=None, fetch=None):
    existing = tasks.by_pr(number, repo)
    if existing and is_open(existing):
        return Imported(existing, created=False)
    if offline:
        raise WkError(f"importing #{number} needs the network")
    if fetch is None:
        from .trackers.github import fetch_pr as fetch

    pr = fetch(number, repo, cwd=cwd)
    if not pr.get("repo"):
        raise WkError(f"could not determine the repo for #{number}")
    existing = tasks.by_pr(number, pr["repo"])
    if existing and is_open(existing):
        return Imported(existing, created=False)
    # Until sync moves to `prs`/`repo`, a PR task is handed to
    # gh_pr_task_sync by the +pr tag and the legacy fields, which completes it
    # on merge. The '#' is part of the stored form so the column reads as a
    # PR reference.
    attrs = {
        "pr_number": f"#{pr['number']}",
        "pr_repo": pr["repo"],
        "project": config.project_for_repo(pr["repo"]),
    }
    return Imported(tasks.add(pr["title"], attrs, tags=["pr"]), created=True)


def import_reference(config, tasks, reference, offline=False, branch=None, cwd=None):
    if reference.kind == "issue":
        return import_issue(config, tasks, reference.value, offline, branch)
    if reference.kind == "pr":
        return import_pr(config, tasks, reference.value, reference.repo, offline, cwd)
    raise WkError(f"a {reference.kind} is not something that can be imported")
