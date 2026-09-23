"""Bring the slow, external state into taskwarrior: my PRs, the reviews asked
of me, and the status of tracked issues.

A sync that cannot reach a service leaves everything in place and records
that it is stale; it is not a failure. Conclusions are only drawn from a
complete answer: a PR missing from a truncated or failed query proves nothing.

Own PRs fold into their work item. Which one, first hit wins, and an attached
PR stays where it is:
  1. the task already listing it (put there by an earlier sync, by hand, or by
     the session that ran `gh pr create`),
  2. the task whose `branch` is the PR's head branch,
  3. the task for the issue key in the head branch, imported if there is
     none yet,
  4. the task of the PR it is stacked on (its base is that PR's head),
  5. else a new PR-only work item.
"""

import datetime
import os

from . import cache
from . import prs as pull_requests
from .errors import Unreachable, WkError
from .locator import issue_key_in
from .tasks import is_open

RECENTLY_CLOSED_DAYS = 14
DONE_STATES = ("completed", "canceled")


def now():
    return datetime.datetime.now(datetime.UTC)


def is_review(task):
    """A review item: someone else's PR, which is the only kind that carries
    the `review` action."""
    return task.get("action") == "review"


def listed_prs(task):
    return [number.strip().lstrip("#") for number in str(task.get("prs", "")).split(",") if number.strip()]


def format_prs(numbers):
    return ",".join(f"#{number}" for number in numbers)


class Report:
    def __init__(self, dry_run=False):
        self.dry_run = dry_run
        self.lines = []
        self.notifications = []
        self.stale = []

    def did(self, text):
        self.lines.append(("would " if self.dry_run else "") + text)


class Sync:
    def __init__(self, config, tasks, github=None, linear=None, dry_run=False, import_issue=None):
        if import_issue is None:
            from .imports import import_issue
        self.import_issue = import_issue
        self.config = config
        self.tasks = tasks
        self.github = github
        self.linear = linear
        self.report = Report(dry_run)
        self.state = cache.read_state()

    # -- plumbing ---------------------------------------------------------

    def _modify(self, task, changes=None, **tags):
        if self.report.dry_run:
            return
        self.tasks.modify(task, changes, **tags)

    def _notify(self, kind, title, body):
        if self.config.data.get("notify", {}).get(kind, True):
            self.report.notifications.append((title, body))

    def _open_tasks(self):
        return [task for task in self.tasks.all() if is_open(task)]

    # -- GitHub -----------------------------------------------------------

    def github_sync(self):
        repos = [name for name, repo in self.config.data["repos"].items() if repo.get("sync")]
        team_requests = self.config.data.get("github", {}).get("team_review_requests", False)
        mine, review, complete = self.github.fetch_open(repos, team_requests)
        first_sync = "prs" not in self.state
        known = self.state.setdefault("prs", {})

        # GitHub computes mergeability lazily and reports UNKNOWN while it
        # recomputes, which is not "no conflict": a conflicted PR would flip
        # to clean and back on every recomputation, notifying each time.
        for pr in mine:
            if pr.get("mergeable") == "UNKNOWN":
                pr["mergeable"] = known.get(f"{pr['repo']}#{pr['number']}", {}).get("mergeable")

        groups = self._fold(mine)
        self._settle_vanished(groups, {(pr["repo"], pr["number"]) for pr in mine})
        for uuid, prs in groups.items():
            self._update_work_item(self.tasks.get(uuid), prs, known, first_sync)
        if complete:
            self._sync_reviews(review, first_sync)
        else:
            self.report.stale.append("review requests (more than one page)")
        for pr in mine:
            known[f"{pr['repo']}#{pr['number']}"] = {
                "status": pull_requests.classify(pr),
                "decision": pr["decision"],
                "mergeable": pr.get("mergeable"),
            }

    def _fold(self, mine):
        """Group my open PRs by the task they belong to, creating PR-only
        items for those that belong to none. Returns {uuid: [pr, …]}."""
        groups = {}
        by_head = {}  # (repo, head branch) -> uuid, filled bottom of the stack first
        for pr in pull_requests.stack_order(mine):
            task = self._task_for(pr)
            key = issue_key_in(pr["head"])
            if task is None and key and self.config.team(key):
                # The branch names an issue of a known team that has no task
                # yet: the PR belongs to that issue, so bring the issue in.
                self.report.did(f"import {key} for #{pr['number']} {pr['title']}")
                if self.report.dry_run:
                    continue
                task = self.import_issue(self.config, self.tasks, key, branch=pr["head"]).task
            if task is None and (pr["repo"], pr["base"]) in by_head:
                task = self.tasks.get(by_head[(pr["repo"], pr["base"])])
            if task is None:
                attrs = {
                    "repo": pr["repo"],
                    "branch": pr["head"],
                    "prs": format_prs([pr["number"]]),
                    "project": self.config.project_for_repo(pr["repo"]),
                }
                self.report.did(f"create a work item for #{pr['number']} {pr['title']}")
                if self.report.dry_run:
                    continue
                task = self.tasks.add(pr["title"], attrs)
            by_head[(pr["repo"], pr["head"])] = task["uuid"]
            groups.setdefault(task["uuid"], []).append(pr)
        return groups

    def _task_for(self, pr):
        candidates = [task for task in self._open_tasks() if not is_review(task)]

        def same_repo(task):
            return not task.get("repo") or task["repo"].lower() == pr["repo"].lower()

        for task in candidates:
            if pr["number"] in listed_prs(task) and same_repo(task):
                return task
        for task in candidates:
            if task.get("branch") == pr["head"] and same_repo(task):
                return task
        key = issue_key_in(pr["head"])
        if key:
            for task in candidates:
                if task.get("issue") == key and same_repo(task):
                    return task
        return None

    def _settle_vanished(self, groups, open_keys):
        """PRs listed on a task but no longer open were merged or closed.
        They stay listed: the task is the hub for everything that touched it,
        before and after it is done. What changes is that they no longer
        count towards the status, and a PR-only item with nothing open left
        is finished."""
        vanished = []
        for task in self._open_tasks():
            if is_review(task) or not task.get("repo"):
                continue
            cached = {pr["number"]: pr for pr in cache.read_prs(task["uuid"])}
            for number in listed_prs(task):
                settled = cached.get(number, {}).get("state") in ("MERGED", "CLOSED")
                if (task["repo"], number) not in open_keys and not settled:
                    vanished.append((task, number, cached.get(number)))
        if not vanished:
            return

        ids = {(task["uuid"], number): pr["id"] for task, number, pr in vanished if pr and pr.get("id")}
        states = self.github.fetch_states(sorted(set(ids.values())))
        outcome = {}
        for task, number, pr in vanished:
            node = ids.get((task["uuid"], number))
            if node:
                state = states.get(node)
            else:
                node, state = self.github.fetch_state(number, task["repo"])
            if state in ("MERGED", "CLOSED"):
                outcome.setdefault(task["uuid"], []).append((number, state, pr or {"number": number, "id": node}))

        for uuid, settled in outcome.items():
            task = self.tasks.get(uuid)
            for number, state, _ in settled:
                self.report.did(f"#{number} {state.lower()} ({task['description']})")
            if not self.report.dry_run:
                # Remembered as settled, so the next sync does not ask again.
                entries = {pr["number"]: pr for pr in cache.read_prs(uuid)}
                for number, state, pr in settled:
                    entries[number] = {**pr, "repo": task["repo"], "state": state}
                cache.write_prs(uuid, [entries[n] for n in listed_prs(task) if n in entries])
            if uuid in groups or task.get("issue"):
                # Still-open PRs set the status below; an issue's fate is the
                # tracker's to decide, so the task itself stays open.
                if uuid not in groups:
                    self._modify(task, {"action": "", "decision": "", "health": ""})
            elif any(state == "MERGED" for _, state, _ in settled):
                self.report.did(f"complete {task['description']}")
                if not self.report.dry_run:
                    self.tasks.done(task)
            else:
                self.report.did(f"delete {task['description']} (closed unmerged)")
                if not self.report.dry_run:
                    self.tasks.delete(task)

    def _update_work_item(self, task, prs, known, first_sync):
        # Settled PRs (merged, closed) keep their place at the front; the
        # open ones follow in stack order.
        current = self.tasks.get(task["uuid"]) or task
        ordered = pull_requests.stack_order(prs)
        open_numbers = [pr["number"] for pr in ordered]
        settled = [n for n in listed_prs(current) if n not in open_numbers]
        listed = settled + open_numbers
        attributes = {key: value or "" for key, value in pull_requests.aggregate(prs).items()}
        changes = {"prs": format_prs(listed), "repo": prs[0]["repo"], **attributes}
        if not current.get("branch") and len(prs) == 1:
            changes["branch"] = prs[0]["head"]
        before = {key: str(current.get(key, "")) for key in changes}
        if before != changes:
            self.report.did(f"update {current['description']}: {changes['prs']} {changes['action']}")
        self._modify(current, changes)
        if not self.report.dry_run:
            entries = {pr["number"]: pr for pr in cache.read_prs(task["uuid"])}
            entries.update({pr["number"]: pr for pr in ordered})
            cache.write_prs(task["uuid"], [entries[n] for n in listed if n in entries])

        if first_sync:
            return
        for pr in prs:
            was = known.get(f"{pr['repo']}#{pr['number']}")
            if not was:
                continue
            health = pull_requests.health_of(pr)
            # Before the attributes split, "status" held one word.
            was_health = was["status"].get("health") if isinstance(was["status"], dict) else was["status"]
            if health == "failing" and was_health != "failing":
                self._notify("checks_failed", f"#{pr['number']} is failing", pr["title"])
            if pr["decision"] != was["decision"] and pr["decision"] in ("APPROVED", "CHANGES_REQUESTED"):
                verdict = "approved" if pr["decision"] == "APPROVED" else "changes requested"
                self._notify("reviewed", f"#{pr['number']} {verdict}", pr["title"])

    def _sync_reviews(self, review, first_sync):
        """Review items: one per PR waiting for my review. Completed when the
        PR leaves that set (I reviewed, or it closed); a re-request creates a
        new one."""
        wanted = {(pr["repo"], pr["number"]): pr for pr in review}
        for task in self._open_tasks():
            if not is_review(task) or not task.get("prs"):
                continue
            key = (task.get("repo"), listed_prs(task)[0])
            if key in wanted:
                pr = wanted.pop(key)
                self._modify(task, pull_requests.classify(pr, mine=False))
                if not self.report.dry_run:
                    cache.write_prs(task["uuid"], [pr])
            else:
                self.report.did(f"complete review of {task['description']}")
                if not self.report.dry_run:
                    self.tasks.done(task)
                    cache.write_prs(task["uuid"], [])
        for pr in wanted.values():
            self.report.did(f"create a review item for #{pr['number']} {pr['title']}")
            if not first_sync:
                self._notify("review_requested", f"Review requested by {pr['author']}", pr["title"])
            if self.report.dry_run:
                continue
            attrs = {
                "repo": pr["repo"],
                "branch": pr["head"],
                "prs": format_prs([pr["number"]]),
                "project": self.config.project_for_repo(pr["repo"]),
                **pull_requests.classify(pr, mine=False),
            }
            task = self.tasks.add(pr["title"], attrs)
            cache.write_prs(task["uuid"], [pr])

    # -- tracker ----------------------------------------------------------

    def tracker_due(self, force=False):
        interval = self.config.data.get("sync", {}).get("tracker_interval", 300)
        last = self.state.get("tracker", {}).get("last_ok")
        if force or not last:
            return True
        return (now() - datetime.datetime.fromisoformat(last)).total_seconds() >= interval

    def tracker_sync(self):
        """Issue status flows to the task, never back, and the tracker wins:
        a completed or cancelled issue completes the task, a reopened one
        revives it. Only issues that changed since the last poll are asked
        about, so this is one small request however many tasks there are."""
        tracker = self.state.setdefault("tracker", {})
        seen = tracker.setdefault("issues", {})
        horizon = (now() - datetime.timedelta(days=RECENTLY_CLOSED_DAYS)).strftime("%Y%m%dT%H%M%SZ")
        tracked = {}
        for task in self.tasks.all():
            key = task.get("issue")
            if not key or self.config.tracker_for_issue(key) != "linear":
                continue
            recent = task.get("status") == "completed" and task.get("end", "") >= horizon
            if is_open(task) or recent:
                if key not in tracked or is_open(task):
                    tracked[key] = task
        started = now()
        stubs = [key for key, task in tracked.items() if "stub" in task.get("tags", [])]
        issues = self.linear.fetch_changed(sorted(tracked), tracker.get("last_ok"), always=stubs)

        for issue in issues:
            task = tracked.get(issue["key"])
            if not task:
                continue
            closed = issue["state"] in DONE_STATES
            was_closed = seen.get(issue["key"]) in DONE_STATES
            seen[issue["key"]] = issue["state"]
            if "stub" in task.get("tags", []) and issue.get("title"):
                self.report.did(f"fill in {issue['key']}: {issue['title']}")
                changes = {"description": issue["title"]}
                parent = self.tasks.by_issue(issue["parent"]) if issue.get("parent") else None
                if parent:
                    changes["partof"] = parent["uuid"]
                self._modify(task, changes, remove_tags=["stub"])
            if closed and is_open(task):
                self.report.did(f"complete {issue['key']} {task['description']} (issue {issue['state']})")
                if not self.report.dry_run:
                    self.tasks.done(task)
            elif not closed and was_closed and task.get("status") == "completed":
                self.report.did(f"revive {issue['key']} {task['description']} (issue reopened)")
                if not self.report.dry_run:
                    self.tasks.revive(task)
        tracker["last_ok"] = started.isoformat()

    # -- run --------------------------------------------------------------

    def run(self, force_tracker=False):
        self.state["last_attempt"] = now().isoformat()
        errors = {}
        steps = [("github", self.github_sync)]
        if self.tracker_due(force_tracker):
            steps.append(("tracker", self.tracker_sync))
        for name, step in steps:
            try:
                step()
                self.tasks.invalidate()
            except Unreachable as err:
                self.report.stale.append(f"{name}: {err}")
                errors[name] = str(err)
            except WkError as err:
                self.report.stale.append(f"{name}: {err}")
                errors[name] = str(err)
        if not self.report.dry_run:
            # Hooks push state as it changes; this catches what they cannot
            # report, such as a crashed agent or a worktree removed by hand.
            from . import state

            state.reap()
            state.refresh(self.tasks, self.config)
        self.state["errors"] = errors
        if "github" not in errors:
            self.state["last_ok"] = now().isoformat()
        if not self.report.dry_run:
            cache.write_state(self.state)
        return self.report


def lock():
    """One sync at a time: the timer and a manual run must not interleave.
    Returns the held lock file, or None when another sync is running."""
    import fcntl

    from .config import xdg

    os.makedirs(xdg("state"), exist_ok=True)
    handle = open(os.path.join(xdg("state"), "sync.lock"), "w")  # noqa: SIM115
    try:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        handle.close()
        return None
    return handle
