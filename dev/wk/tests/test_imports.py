import pytest
from conftest import needs_task

from wk.errors import NotFound, Unreachable, WkError
from wk.imports import import_issue, import_pr

pytestmark = needs_task


def issue(title="Fix the thing", parent=None):
    return lambda key: {"key": key, "title": title, "parent": parent}


def unreachable(_key):
    raise Unreachable("no network")


def test_import_creates_the_task_in_the_teams_project(config, tasks):
    result = import_issue(config, tasks, "ACME-12", fetch=issue("fix: a+b"))
    assert result.created and not result.stub
    assert result.task["description"] == "fix: a+b"
    assert result.task["issue"] == "ACME-12"
    assert result.task["project"] == "work"


def test_importing_twice_is_a_no_op_and_asks_nobody(config, tasks):
    first = import_issue(config, tasks, "ACME-12", fetch=issue())
    again = import_issue(config, tasks, "ACME-12", fetch=unreachable)
    assert not again.created
    assert again.task["uuid"] == first.task["uuid"]


def test_a_closed_task_does_not_block_a_new_import(config, tasks):
    first = import_issue(config, tasks, "ACME-12", fetch=issue())
    tasks._task([first.task["uuid"], "done"])
    tasks.invalidate()
    assert import_issue(config, tasks, "ACME-12", fetch=issue()).created


def test_unreachable_tracker_yields_a_stub_from_the_branch(config, tasks):
    result = import_issue(config, tasks, "ACME-12", branch="someone/acme-12-fix-the-thing", fetch=unreachable)
    assert result.stub
    assert result.task["description"] == "fix the thing"
    assert result.task["branch"] == "someone/acme-12-fix-the-thing"
    assert "stub" in result.task["tags"]


def test_offline_never_calls_the_tracker(config, tasks):
    def boom(_key):
        raise AssertionError("asked the tracker")

    result = import_issue(config, tasks, "ACME-13", offline=True, fetch=boom)
    assert result.stub
    assert result.task["description"] == "ACME-13"


def test_a_tracker_error_is_not_mistaken_for_being_offline(config, tasks):
    def missing(key):
        raise NotFound(f"issue {key} not found")

    with pytest.raises(NotFound):
        import_issue(config, tasks, "ACME-404", fetch=missing)
    assert tasks.by_issue("ACME-404") is None


def test_sub_issue_links_to_its_parents_task_when_there_is_one(config, tasks):
    parent = import_issue(config, tasks, "ACME-1", fetch=issue("Investigate"))
    child = import_issue(config, tasks, "ACME-2", fetch=issue("One part", parent="ACME-1"))
    orphan = import_issue(config, tasks, "ACME-3", fetch=issue("Other part", parent="ACME-99"))
    assert child.task["partof"] == parent.task["uuid"]
    assert "partof" not in orphan.task


def test_pr_import(world, config, tasks):
    (world / "taskrc").open("a").write("uda.pr_number.type=string\nuda.pr_repo.type=string\n")

    def fetch(number, repo, cwd=None):
        return {"number": str(number), "title": "feat: thing", "repo": repo or "acme/app"}

    result = import_pr(config, tasks, "77", fetch=fetch)
    assert result.task["pr_number"] == "#77"
    assert result.task["pr_repo"] == "acme/app"
    assert result.task["project"] == "work"
    assert not import_pr(config, tasks, "77", "acme/app", fetch=fetch).created
    with pytest.raises(WkError):
        import_pr(config, tasks, "78", offline=True)
