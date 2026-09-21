from conftest import needs_task

pytestmark = needs_task


def test_add_returns_the_task_and_keeps_the_title_verbatim(tasks):
    task = tasks.add("fix(api): handle a+b due:tomorrow", {"issue": "ACME-1", "project": "work"})
    assert task["description"] == "fix(api): handle a+b due:tomorrow"
    assert task["issue"] == "ACME-1"
    assert task["project"] == "work"
    assert "due" not in task


def test_issue_lookup_is_exact_not_a_prefix_match(tasks):
    tasks.add("long", {"issue": "ACME-852"})
    assert tasks.by_issue("ACME-85") is None
    assert tasks.by_issue("acme-852")["description"] == "long"


def test_lookups_prefer_open_tasks(tasks):
    first = tasks.add("first", {"issue": "ACME-7"})
    tasks._task([first["uuid"], "done"])
    tasks.invalidate()
    second = tasks.add("second", {"issue": "ACME-7"})
    assert tasks.by_issue("ACME-7")["uuid"] == second["uuid"]


def test_get_by_working_set_id_and_uuid(tasks):
    task = tasks.add("something")
    assert tasks.get(str(task["id"]))["uuid"] == task["uuid"]
    assert tasks.get(task["uuid"].upper())["uuid"] == task["uuid"]
    assert tasks.get("999") is None


def test_modify_writes_only_what_differs(tasks):
    task = tasks.add("something", {"issue": "ACME-2"})
    assert tasks.modify(task, {"issue": "ACME-2"}) is False
    assert tasks.modify(task, {"note": "wiki/tasks/ACME-2 Some thing"}) is True
    assert tasks.get(task["uuid"])["note"] == "wiki/tasks/ACME-2 Some thing"
    assert tasks.modify(tasks.get(task["uuid"]), {"note": None}) is True
    assert "note" not in tasks.get(task["uuid"])


def test_modify_tags(tasks):
    task = tasks.add("something", tags=["stub"])
    assert tasks.modify(task, add_tags=["stub"]) is False
    assert tasks.modify(task, remove_tags=["stub"]) is True
    assert "stub" not in tasks.get(task["uuid"]).get("tags", [])


def test_worktree_match_prefers_the_deepest(tasks, tmp_path):
    outer, inner = tmp_path / "repo", tmp_path / "repo" / ".worktrees" / "acme-3"
    (inner / "src").mkdir(parents=True)
    tasks.add("outer", {"worktree": str(outer)})
    tasks.add("inner", {"worktree": str(inner)})
    assert tasks.by_worktree(str(inner / "src"))["description"] == "inner"
    assert tasks.by_worktree(str(outer))["description"] == "outer"
    assert tasks.by_worktree(str(tmp_path)) is None
    # A sibling sharing a name prefix is not inside the worktree.
    assert tasks.by_worktree(str(tmp_path / "repo-two")) is None


def test_pr_lookup_reads_legacy_values(world, tasks):
    (world / "taskrc").open("a").write("uda.pr_number.type=string\nuda.pr_repo.type=string\n")
    tasks.add("merge me", {"pr_number": "#10307", "pr_repo": "acme/app"})
    assert tasks.by_pr("10307")["description"] == "merge me"
    assert tasks.by_pr("#10307", "acme/app")["description"] == "merge me"
    assert tasks.by_pr("10307", "other/repo") is None
    assert tasks.by_pr("1030") is None
