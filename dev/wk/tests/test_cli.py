import json
import os

import pytest
from conftest import needs_task

from wk import cli
from wk.errors import Unreachable

pytestmark = needs_task


def run(capsys, *argv):
    code = cli.main(list(argv))
    captured = capsys.readouterr()
    return code, captured.out, captured.err


@pytest.fixture
def offline(monkeypatch):
    def unreachable(_key):
        raise Unreachable("no network")

    monkeypatch.setattr("wk.trackers.linear.fetch_issue", unreachable)


def test_resolve_here_as_json(capsys, tasks, repo):
    task = tasks.add("the thing", {"issue": "ACME-12", "project": "work"})
    code, out, _ = run(capsys, "resolve", "--json", "-C", str(repo))
    payload = json.loads(out)
    assert code == 0
    assert payload["ok"] is True
    assert payload["task"]["uuid"] == task["uuid"]
    assert payload["task"]["kind"] == "work"
    assert payload["issue"] == "ACME-12"
    assert payload["note"] is None  # plain resolve never creates anything


def test_resolve_without_a_task_exits_2_but_names_the_issue(capsys, world, repo):
    code, out, _ = run(capsys, "resolve", "--json", "-C", str(repo))
    assert code == 2
    assert json.loads(out) == {
        "ok": False,
        "error": {"code": "not_found", "message": "no task for ACME-12"},
        "issue": "ACME-12",
        "branch": "someone/acme-12-fix-the-thing",
    }


def test_resolve_ensure_imports_and_creates_the_note(capsys, world, repo, offline):
    code, out, _ = run(capsys, "resolve", "--ensure", "-C", str(repo))
    lines = dict(line.split("=", 1) for line in out.splitlines())
    assert code == 0
    assert lines["issue"] == "ACME-12"
    assert lines["vault"] == str(world / "vaults/acme")
    assert lines["note"] == str(world / "vaults/acme/wiki/tasks/ACME-12 fix the thing.md")


def test_format_prints_what_is_known_even_without_a_task(capsys, world, repo):
    code, out, _ = run(capsys, "resolve", "--offline", "--format", "fixes: {issue}", "-C", str(repo))
    assert (code, out) == (2, "fixes: ACME-12\n")


def test_format_is_all_or_nothing(capsys, world):
    assert run(capsys, "resolve", "--offline", "--format", "fixes: {issue}")[:2] == (2, "")


def test_import_ignores_the_uuid_the_tui_appends(capsys, world, repo, offline):
    selected = "0b1c2d3e-a12e-197a-8b9c-0d1e2f3a4b5c"
    code, out, _ = run(capsys, "import", "-C", str(repo), selected)
    assert code == 0
    assert out.startswith("Task added (tracker unreachable")
    assert "[ACME-12]" in out


def test_import_with_nothing_to_go_on(capsys, world):
    code, _, err = run(capsys, "import")
    assert code == 2
    assert "no issue or PR reference" in err


def test_note_print(capsys, tasks, world):
    task = tasks.add("the thing", {"issue": "ACME-12", "project": "work"})
    code, out, _ = run(capsys, "note", "--print", task["uuid"])
    assert code == 0
    assert out.strip() == str(world / "vaults/acme/wiki/tasks/ACME-12 the thing.md")


def test_config_get(capsys, world):
    assert run(capsys, "config", "get", "teams.ACME.workspace")[:2] == (0, "acme\n")
    assert run(capsys, "config", "get", "repos.acme/app.project")[:2] == (0, "work\n")
    assert run(capsys, "config", "get", "teams.NOPE.workspace")[0] == 2


@needs_task
def test_attach_pr_refuses_what_is_not_a_pr(tasks, world):
    task = tasks.add("the thing", {"issue": "ACME-12", "worktree": str(world)})
    assert cli.main(["attach-pr", f"#10999 {task['uuid']}"]) == 2
    tasks.invalidate()
    assert "prs" not in tasks.get(task["uuid"])


def test_an_issue_filed_mid_session_goes_to_the_sessions_task(capsys, tasks, world, monkeypatch):
    """Adopted first, issue filed later: `resolve --issue` gives the task the
    issue and the note follows, rather than a second task and note."""
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s1")
    monkeypatch.setattr("wk.trackers.linear.fetch_issue", lambda key: {"key": key, "title": "Fix the export"})
    adopted = tasks.add("export investigation", {"session": "s1", "project": "inbox"})
    old = json.loads(run(capsys, "resolve", "--ensure", "--json")[1])["note"]
    with open(old, "a") as handle:
        handle.write("- found the thing\n")

    code, out, _ = run(capsys, "resolve", "--ensure", "--json", "--issue", "acme-77")
    payload = json.loads(out)
    assert code == 0
    assert payload["task"]["uuid"] == adopted["uuid"]
    assert payload["how"] == "session"
    tasks.invalidate()
    assert len(tasks.all()) == 1, "nothing was imported"
    task = tasks.get(adopted["uuid"])
    assert task["issue"] == "ACME-77" and task["project"] == "work" and task["description"] == "Fix the export"
    # The project moved to the issue's, and the note to that project's vault.
    assert payload["note"] == str(world / "vaults/acme/wiki/tasks/ACME-77 Fix the export.md")
    text = open(payload["note"]).read()
    assert f"task: {adopted['uuid']}" in text and "issue: ACME-77" in text and "project: work" in text
    assert "# ACME-77 Fix the export\n" in text and "- found the thing" in text
    assert not os.path.exists(old)
    assert task["note"] == "wiki/tasks/ACME-77 Fix the export"


def test_the_note_is_renamed_in_place_and_links_follow(capsys, tasks, world, monkeypatch, offline):
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s1")
    adopted = tasks.add("export investigation", {"session": "s1", "project": "work"})
    old = json.loads(run(capsys, "resolve", "--ensure", "--json")[1])["note"]
    name = os.path.basename(old)[: -len(".md")]
    daily = world / "vaults/acme/wiki/daily.md"
    daily.write_text(f"- [[{name}]] and [[wiki/tasks/{name}|alias]] and [[{name}#Findings]] and [[x{name}]]\n")

    assert run(capsys, "resolve", "--ensure", "--issue", "ACME-78")[0] == 0
    assert daily.read_text() == (
        "- [[ACME-78 export investigation]] and [[wiki/tasks/ACME-78 export investigation|alias]]"
        f" and [[ACME-78 export investigation#Findings]] and [[x{name}]]\n"
    )
    tasks.invalidate()
    assert tasks.get(adopted["uuid"])["issue"] == "ACME-78"


def test_an_issue_named_for_another_sessions_task_is_imported(capsys, tasks, world, monkeypatch, offline):
    """A window's task this session is not recorded on keeps what it has;
    the issue gets a task of its own."""
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s2")
    other = tasks.add("orchestration", {"session": "s1"})
    monkeypatch.setattr("wk.tmux.current_task", lambda: other["uuid"])
    payload = json.loads(run(capsys, "resolve", "--ensure", "--json", "--issue", "ACME-79")[1])
    assert payload["task"]["uuid"] != other["uuid"]
    tasks.invalidate()
    assert "issue" not in tasks.get(other["uuid"])
