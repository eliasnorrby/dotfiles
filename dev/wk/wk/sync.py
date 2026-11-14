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

A parent answers for its sub-tasks' PRs as well as its own: it lists them in
`subprs` and its action, decision and health cover them. They still belong to
the sub-task; this is only so the list can show the stack by its parent.

One local step rides along: task notes are filed where their task's status
says they belong (see notes_sync).
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
        below = self._below(groups)
        self._settle_vanished(groups, below, {(pr["repo"], pr["number"]) for pr in mine})
        rolled_up = {task["uuid"] for task in self._open_tasks() if task.get("subprs")}
        for uuid in dict.fromkeys([*groups, *below, *rolled_up]):
            self._update_work_item(self.tasks.get(uuid), groups.get(uuid, []), known, first_sync, below.get(uuid, []))
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

    def _below(self, groups):
        """The open PRs of each task's open sub-tasks, by the parent's uuid.
        A PR has one owner, its sub-task; the parent only shows the stack
        (`subprs`) and answers for it (action, decision, health), so the
        sub-tasks can stay out of the list."""
        open_tasks = self._open_tasks()
        parents = {task["uuid"] for task in open_tasks}
        below = {}
        for task in open_tasks:
            if task.get("partof") in parents and task["uuid"] in groups:
                below.setdefault(task["partof"], []).extend(groups[task["uuid"]])
        return below

    def _settle_vanished(self, groups, below, open_keys):
        """PRs listed on a task but no longer open were merged or closed.
        A merged one stays listed: the task is the hub for everything that
        landed on it, before and after it is done. A closed one leaves the
        list, since nothing of it survives to point back at. Either way it
        no longer counts towards the status, and a PR-only item with nothing
        open left is finished: one without an issue or sub-tasks, whose PRs
        are its own (see _held_open)."""
        vanished = []
        stale = {}  # closed PRs listed before closed ones were dropped
        for task in self._open_tasks():
            if is_review(task) or not task.get("repo"):
                continue
            cached = {pr["number"]: pr for pr in cache.read_prs(task["uuid"])}
            for number in listed_prs(task):
                state = cached.get(number, {}).get("state")
                if state == "CLOSED":
                    stale.setdefault(task["uuid"], []).append(number)
                elif (task["repo"], number) not in open_keys and state != "MERGED":
                    vanished.append((task, number, cached.get(number)))
        for uuid, numbers in stale.items():
            task = self.tasks.get(uuid)
            self.report.did(f"drop {format_prs(numbers)} from {task['description']} (closed unmerged)")
            self._modify(task, {"prs": format_prs(self._keep_prs(task, numbers))})
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

        parents = self._parents()
        for uuid, settled in outcome.items():
            task = self.tasks.get(uuid)
            for number, state, _ in settled:
                self.report.did(f"#{number} {state.lower()} ({task['description']})")
            closed = [number for number, state, _ in settled if state == "CLOSED"]
            entries = {pr["number"]: pr for pr in cache.read_prs(uuid)}
            heads = {pr.get("head") for pr in entries.values()} | {pr.get("head") for _, _, pr in settled}
            if not self.report.dry_run:
                # Merged ones are remembered as settled, so the next sync
                # does not ask again; closed ones are no longer listed to
                # ask about.
                for number, state, pr in settled:
                    entries[number] = {**pr, "repo": task["repo"], "state": state}
                cache.write_prs(uuid, [entries[n] for n in self._keep_prs(task, closed) if n in entries])
            changes = {"prs": format_prs(self._keep_prs(task, closed))} if closed else {}
            held = self._held_open(task, groups, parents, heads)
            if held:
                # Still-open PRs set the status below; an issue's fate is the
                # tracker's to decide; a task that is more than its PRs
                # outlives them. Either way the task itself stays open.
                if uuid not in groups and uuid not in below:
                    changes.update({"action": "", "decision": "", "health": ""})
                    if not task.get("issue"):
                        self.report.did(f"keep {task['description']} open ({held})")
                if changes:
                    self._modify(task, changes)
            elif any(state == "MERGED" for _, state, _ in settled):
                merged = format_prs(number for number, state, _ in settled if state == "MERGED")
                self.report.did(f"complete {task['description']}")
                if not self.report.dry_run:
                    self._modify(task, changes)
                    self.tasks.done(task)
                    self._tell_sessions(task, f"{merged} merged")
            else:
                self.report.did(f"delete {task['description']} (closed unmerged)")
                if not self.report.dry_run:
                    self.tasks.delete(task)

    def _parents(self):
        """The tasks that an open or recently completed task is part of. A
        parent is more than its own PRs: its sub-tasks' work goes on after
        any one PR lands, and they finish one by one, so it stays a parent
        for a while after the last of them."""
        horizon = (now() - datetime.timedelta(days=RECENTLY_CLOSED_DAYS)).strftime("%Y%m%dT%H%M%SZ")
        return {
            task["partof"]
            for task in self.tasks.all()
            if task.get("partof")
            and (is_open(task) or (task.get("status") == "completed" and task.get("end", "") >= horizon))
        }

    @staticmethod
    def _held_open(task, groups, parents, heads):
        """Why the task outlives the PRs that just settled, or None for a
        PR-only item, which ends with them. `heads` are the head branches of
        its PRs, as far as they are known.

        A task without an issue ends with its PRs only when they are its
        own: one was opened from the task's branch. What sync or `wk import`
        made of a PR records that branch, and so does a task adopted on it.
        A session's task that merely had a side PR attached (a fix split out
        of a review, a sub-task's PR its parent collected) has another
        branch, or none, and is not done when that PR lands."""
        if task["uuid"] in groups:
            return "PRs still open"
        if task.get("issue"):
            return "the tracker decides"
        if task["uuid"] in parents:
            return "it has sub-tasks"
        if not task.get("branch") or task["branch"] not in heads:
            return "not its own PR"
        return None

    def _tell_sessions(self, task, reason):
        """Leave word for the live Claude sessions on the task, handed to them
        with their next prompt: a session should hear it from wk, not from a
        note that moved away under it."""
        from . import state

        label = " ".join(filter(None, [task.get("issue"), task["description"]]))
        text = (
            f"wk sync completed task {task['uuid'][:8]} ({label}): {reason}. Its note is archived now."
            f" If the work goes on, reopen it (`task {task['uuid']} modify status:pending end:`)"
            " before the next checkpoint."
        )
        for session_id, agent in state.agents().items():
            if agent.get("uuid") == task["uuid"]:
                state.post_notice(session_id, text)

    @staticmethod
    def _keep_prs(task, dropped):
        return [number for number in listed_prs(task) if number not in dropped]

    def _update_work_item(self, task, prs, known, first_sync, below=()):
        """`prs` are the task's own open PRs, `below` its sub-tasks'. Either
        may be empty: a parent can answer for its sub-tasks alone, and a
        parent whose sub-tasks' PRs are gone has its rollup cleared."""
        current = self.tasks.get(task["uuid"]) or task
        attributes = pull_requests.aggregate(list(prs) + list(below))
        changes = {key: value or "" for key, value in attributes.items()}
        changes["subprs"] = format_prs(pr["number"] for pr in pull_requests.stack_order(below))
        # Settled PRs (merged, closed) keep their place at the front; the
        # open ones follow in stack order.
        ordered = pull_requests.stack_order(prs)
        open_numbers = [pr["number"] for pr in ordered]
        settled = [n for n in listed_prs(current) if n not in open_numbers]
        listed = settled + open_numbers
        if prs:
            changes["prs"] = format_prs(listed)
            changes["repo"] = prs[0]["repo"]
        if not current.get("branch") and current.get("issue") and len(prs) == 1:
            # Never on a task without an issue: its branch is what makes a PR
            # its own (see _held_open), and a PR attached to it is no proof.
            changes["branch"] = prs[0]["head"]
        before = {key: str(current.get(key, "")) for key in changes}
        if before != changes:
            shown = " ".join(filter(None, [format_prs(listed), changes["subprs"], changes["action"]]))
            self.report.did(f"update {current['description']}: {shown}")
        self._modify(current, changes)
        if prs and not self.report.dry_run:
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
                    self._tell_sessions(task, f"{issue['key']} was {issue['state']} in the tracker")
            elif not closed and was_closed and task.get("status") == "completed":
                self.report.did(f"revive {issue['key']} {task['description']} (issue reopened)")
                if not self.report.dry_run:
                    self.tasks.revive(task)
        tracker["last_ok"] = started.isoformat()

    # -- notes ------------------------------------------------------------

    def notes_sync(self):
        """A task's note lives in the archive while the task is closed and
        out of it while the task is open. The hook moves it at every status
        change, but not a note made after its task closed, nor one it missed
        (`task undo`, a note it could not find then): this catches up.

        Local and cheap enough for every minute: the cached `note` path says
        where each note is, so a task whose note is where it belongs costs no
        I/O at all. Only a vault with a repository is touched (one without is
        a synced copy), and only a note found at its cached path."""
        from . import notes

        if not self.config.registers_work:
            return
        for task in self.tasks.all():
            cached = task.get("note")
            if not cached or not (is_open(task) or notes.is_closed(task)):
                continue
            closed = notes.is_closed(task)
            if notes.is_archived(self.config, cached) == closed:
                continue
            vault = os.path.join(self.config.vaults_dir, self.config.vault_for_project(task.get("project")))
            path = os.path.join(vault, cached + ".md")
            target = os.path.join(notes.home_of(self.config, vault, closed), os.path.basename(path))
            if not os.path.isdir(os.path.join(vault, ".git")):
                continue
            if not os.path.isfile(path):
                if os.path.isfile(target):
                    # Moved already (`task undo` reverts the cached path,
                    # not the file): only the cached path is stale.
                    self.report.did(f"repair the note path of {task['description']}")
                    self._modify(task, {"note": os.path.splitext(os.path.relpath(target, vault))[0]})
                continue
            if os.path.exists(target):
                continue  # another note in the way, which is not ours to settle
            self.report.did(f"{'archive' if closed else 'restore'} the note of {task['description']}")
            if self.report.dry_run:
                continue
            try:
                moved = notes.move_for_status(self.config, task, closed, path=path)
            except OSError as err:
                self.report.stale.append(f"notes: {err}")
                continue
            if moved:
                self._modify(task, {"note": moved})

    # -- run --------------------------------------------------------------

    def run(self, force_tracker=False):
        self.state["last_attempt"] = now().isoformat()
        errors = {}
        steps = [("github", self.github_sync)]
        if self.tracker_due(force_tracker):
            steps.append(("tracker", self.tracker_sync))
        steps.append(("notes", self.notes_sync))
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
