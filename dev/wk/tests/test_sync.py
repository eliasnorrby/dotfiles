import pytest
from conftest import needs_task

from wk import cache
from wk.errors import Unreachable
from wk.sync import Sync, listed_prs

pytestmark = needs_task


def pr(number, head, base="main", author="me", **fields):
    return {
        "id": f"node{number}",
        "number": str(number),
        "title": f"PR {number}",
        "url": f"https://github.com/acme/app/pull/{number}",
        "repo": "acme/app",
        "author": author,
        "head": head,
        "base": base,
        "draft": False,
        "mergeable": "MERGEABLE",
        "decision": "REVIEW_REQUIRED",
        "checks": "SUCCESS",
        **fields,
    }


class GitHub:
    def __init__(self, mine=(), review=(), states=None, complete=True):
        self.mine, self.review, self.states, self.complete = list(mine), list(review), states or {}, complete

    def fetch_open(self, repos, team_requests=False):
        assert repos == ["acme/app"]
        return self.mine, self.review, self.complete

    def fetch_states(self, ids):
        return {node: self.states[node] for node in ids}

    def fetch_state(self, number, repo):
        return f"node{number}", self.states[f"node{number}"]


class Linear:
    def __init__(self, issues=()):
        self.issues, self.calls = list(issues), []

    def fetch_changed(self, keys, since=None, always=()):
        self.calls.append((keys, since, list(always)))
        return self.issues


@pytest.fixture
def world_with_sync(world, monkeypatch):
    (world / "config.toml").open("a").write("sync = true\n[sync]\ntracker_interval = 0\n")
    monkeypatch.setenv("XDG_CACHE_HOME", str(world / "cache"))
    monkeypatch.setenv("XDG_STATE_HOME", str(world / "state"))
    return world


def fake_import(config, tasks, key, branch=None):
    from wk.imports import Imported

    return Imported(tasks.add(f"Imported {key}", {"issue": key, "branch": branch}), created=True)


def sync(tasks, github=None, linear=None, dry_run=False):
    from wk.config import Config

    report = Sync(Config.load(), tasks, github or GitHub(), linear or Linear(), dry_run, fake_import).run()
    tasks.invalidate()
    return report


def test_prs_fold_into_their_work_item(world_with_sync, tasks):
    by_branch = tasks.add("untracked refactor", {"branch": "me/replace-the-feature"})
    by_issue = tasks.add("Fix the thing", {"issue": "ACME-12"})
    sync(
        tasks,
        GitHub(
            mine=[
                pr(10, "me/replace-the-feature", checks="FAILURE"),
                pr(11, "me/acme-12-fix", decision="APPROVED"),
                pr(12, "me/no-home-for-this"),
            ]
        ),
    )
    assert tasks.get(by_branch["uuid"])["prs"] == "#10"
    assert tasks.get(by_branch["uuid"])["prstatus"] == "failing"
    assert tasks.get(by_issue["uuid"])["prs"] == "#11"
    assert tasks.get(by_issue["uuid"])["prstatus"] == "approved"
    orphan = tasks.by_pr("12", "acme/app")
    assert orphan["description"] == "PR 12"
    assert orphan["branch"] == "me/no-home-for-this"
    assert orphan["project"] == "work"
    assert cache.read_prs(orphan["uuid"])[0]["url"].endswith("/12")


def test_a_branch_naming_an_unimported_issue_imports_it(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(11, "me/acme-12-fix"), pr(12, "me/other-9-not-a-known-team")]))
    assert tasks.by_issue("ACME-12")["prs"] == "#11"
    assert "issue" not in tasks.by_pr("12")


def test_a_stack_is_listed_bottom_first_with_the_worst_status(world_with_sync, tasks):
    task = tasks.add("the stack", {"prs": "#22,#21,#20", "repo": "acme/app"})
    sync(tasks, GitHub(mine=[pr(22, "c", "b"), pr(20, "a"), pr(21, "b", "a", draft=True)]))
    task = tasks.get(task["uuid"])
    assert task["prs"] == "#20,#21,#22"
    assert task["prstatus"] == "review"


def test_a_new_stack_shares_one_work_item(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(22, "c", "b"), pr(21, "b", "a"), pr(20, "a"), pr(23, "solo")]))
    assert tasks.by_pr("22")["prs"] == "#20,#21,#22"
    assert tasks.by_pr("22")["description"] == "PR 20"
    assert tasks.by_pr("23")["prs"] == "#23"


def test_an_attached_pr_stays_put(world_with_sync, tasks):
    parent = tasks.add("investigation", {"issue": "ACME-1", "prs": "#30", "repo": "acme/app"})
    child = tasks.add("the sub-issue", {"issue": "ACME-2"})
    sync(tasks, GitHub(mine=[pr(30, "me/acme-2-part")]))
    assert tasks.get(parent["uuid"])["prs"] == "#30"
    assert "prs" not in tasks.get(child["uuid"])


def test_nothing_changes_nothing_is_written(world_with_sync, tasks):
    github = GitHub(mine=[pr(10, "me/x")])
    sync(tasks, github)
    modified = tasks.by_pr("10")["modified"]
    assert sync(tasks, github).lines == []
    assert tasks.by_pr("10")["modified"] == modified


def test_merged_pr_completes_a_pr_only_item_but_not_issue_work(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(10, "me/x"), pr(11, "me/acme-12-fix")]))
    tracked = tasks.add("Fix the thing", {"issue": "ACME-13", "prs": "#12", "repo": "acme/app"})
    sync(tasks, GitHub(mine=[pr(11, "me/acme-12-fix")], states={"node10": "MERGED", "node12": "MERGED"}))
    done = tasks.by_pr("10")
    assert done["status"] == "completed"
    assert done["prs"] == "#10"  # the hub keeps what touched the task
    assert cache.read_prs(done["uuid"])[0]["state"] == "MERGED"
    tracked = tasks.get(tracked["uuid"])
    assert tracked["status"] == "pending"
    assert tracked["prs"] == "#12" and "prstatus" not in tracked


def test_a_settled_pr_is_not_asked_about_again(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(10, "me/x"), pr(11, "me/y")]))

    class Strict(GitHub):
        def fetch_states(self, ids):
            assert ids == ["node10"]
            return {"node10": "MERGED"}

        def fetch_state(self, number, repo):
            raise AssertionError("asked one by one")

    sync(tasks, Strict(mine=[pr(11, "me/y")]))
    sync(tasks, Strict(mine=[pr(11, "me/y")]))  # nothing new to ask


def test_closed_unmerged_pr_deletes_a_pr_only_item(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(10, "me/x")]))
    uuid = tasks.by_pr("10")["uuid"]
    sync(tasks, GitHub(states={"node10": "CLOSED"}))
    assert tasks.get(uuid)["status"] == "deleted"


def test_one_of_a_stack_merging_keeps_the_rest(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(20, "a"), pr(21, "b", "a")]))
    uuid = tasks.by_pr("20")["uuid"]
    tasks.modify(tasks.get(uuid), {"prs": "#20,#21"})
    sync(tasks, GitHub(mine=[pr(21, "b", "main")], states={"node20": "MERGED"}))
    assert listed_prs(tasks.get(uuid)) == ["20", "21"]
    assert tasks.get(uuid)["prstatus"] == "review"
    assert tasks.get(uuid)["status"] == "pending"


def test_review_items_come_and_go(world_with_sync, tasks):
    theirs = pr(40, "them/feature", author="them")
    sync(tasks, GitHub(review=[theirs]))
    item = tasks.by_pr("40")
    assert "review" in item["tags"]
    assert "prstatus" not in item
    assert sync(tasks, GitHub(review=[theirs])).lines == []

    sync(tasks, GitHub(review=[]))
    assert tasks.get(item["uuid"])["status"] == "completed"
    sync(tasks, GitHub(review=[theirs]))  # re-requested
    assert tasks.by_pr("40")["uuid"] != item["uuid"]


def test_a_truncated_answer_completes_no_reviews(world_with_sync, tasks):
    sync(tasks, GitHub(review=[pr(40, "them/feature", author="them")]))
    report = sync(tasks, GitHub(review=[], complete=False))
    assert tasks.by_pr("40")["status"] == "pending"
    assert report.stale


def test_unreachable_github_leaves_everything_in_place(world_with_sync, tasks):
    sync(tasks, GitHub(mine=[pr(10, "me/x")]))

    class Down(GitHub):
        def fetch_open(self, repos, team_requests=False):
            raise Unreachable("HTTP 504")

    report = sync(tasks, Down())
    assert tasks.by_pr("10")["status"] == "pending"
    assert report.stale == ["github: HTTP 504"]
    assert cache.read_state()["errors"] == {"github": "HTTP 504"}


def test_dry_run_writes_nothing(world_with_sync, tasks):
    report = sync(tasks, GitHub(mine=[pr(10, "me/x")]), dry_run=True)
    assert report.lines == ["would create a work item for #10 PR 10"]
    assert tasks.by_pr("10") is None
    assert cache.read_state() == {}


def test_notifications_only_on_transitions_after_the_first_sync(world_with_sync, tasks):
    first = sync(tasks, GitHub(mine=[pr(10, "me/x")], review=[pr(40, "them/f", author="them")]))
    assert first.notifications == []
    second = sync(
        tasks,
        GitHub(
            mine=[pr(10, "me/x", checks="FAILURE", decision="APPROVED")],
            review=[pr(40, "them/f", author="them"), pr(41, "them/g", author="them")],
        ),
    )
    assert [title for title, _ in second.notifications] == [
        "#10 is failing",
        "#10 approved",
        "Review requested by them",
    ]
    assert sync(tasks, GitHub(mine=[pr(10, "me/x", checks="FAILURE", decision="APPROVED")])).notifications == []


def test_tracker_status_flows_to_the_task(world_with_sync, tasks):
    task = tasks.add("Fix the thing", {"issue": "ACME-12"})
    linear = Linear([{"key": "ACME-12", "title": "Fix the thing", "state": "completed", "parent": None}])
    sync(tasks, linear=linear)
    assert linear.calls[0][:2] == (["ACME-12"], None)
    assert tasks.get(task["uuid"])["status"] == "completed"

    linear.issues = [{"key": "ACME-12", "title": "Fix the thing", "state": "started", "parent": None}]
    sync(tasks, linear=linear)
    assert linear.calls[1][1] is not None  # only what changed since the last poll
    assert tasks.get(task["uuid"])["status"] == "pending"


def test_a_task_i_closed_myself_is_not_revived_by_unrelated_issue_activity(world_with_sync, tasks):
    task = tasks.add("Fix the thing", {"issue": "ACME-12"})
    tasks.done(task)
    sync(tasks, linear=Linear([{"key": "ACME-12", "title": "Fix the thing", "state": "started", "parent": None}]))
    assert tasks.get(task["uuid"])["status"] == "completed"


def test_stubs_are_filled_in(world_with_sync, tasks):
    parent = tasks.add("Investigate", {"issue": "ACME-1"})
    stub = tasks.add("fix the thing", {"issue": "ACME-12"}, tags=["stub"])
    sync(tasks, linear=Linear([{"key": "ACME-12", "title": "Fix: the thing", "state": "started", "parent": "ACME-1"}]))
    stub = tasks.get(stub["uuid"])
    assert stub["description"] == "Fix: the thing"
    assert stub["partof"] == parent["uuid"]
    assert "stub" not in stub.get("tags", [])
