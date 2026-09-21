import json
import os

import pytest
from conftest import needs_task

from wk import cli, hooks, state

pytestmark = needs_task


@pytest.fixture
def stateful(world, monkeypatch):
    monkeypatch.setenv("XDG_STATE_HOME", str(world / "state"))
    monkeypatch.setenv("CLAUDE_PID", str(os.getpid()))
    return world


def event(name, session="s1", **payload):
    hooks.claude_event(name, {"session_id": session, **payload})


def state_of(tasks, task):
    tasks.invalidate()
    return tasks.get(task["uuid"]).get("state", "")


def test_the_topmost_state_wins(tasks, stateful, tmp_path):
    task = tasks.add("work", {"worktree": str(tmp_path), "session": "old"})
    assert state.compute(task, {}, set()) == "checkout"
    assert state.compute(task, {}, {task["uuid"]}) == "window"
    assert state.compute(task, {task["uuid"]: {"idle", "input"}}, {task["uuid"]}) == "input"
    assert state.compute({**task, "worktree": "/gone"}, {}, set()) == "resume"
    assert state.compute(tasks.add("bare"), {}, set()) == ""


def test_a_sessions_life_moves_the_tasks_state(tasks, stateful, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    event("session-start", cwd=str(repo), source="startup")
    assert state_of(tasks, task) == "idle"
    assert tasks.get(task["uuid"])["session"] == "s1"
    assert tasks.get(task["uuid"])["state_flag"] == state.FLAGS["idle"]

    event("user-prompt-submit")
    assert state_of(tasks, task) == "working"
    event("notification", notification_type="permission_prompt", message="Claude needs your permission")
    assert state_of(tasks, task) == "input"
    event("notification", notification_type="idle_prompt", message="Claude is waiting for your input")
    assert state_of(tasks, task) == "input"  # a pending question is never downgraded
    event("post-tool-use", tool_name="Read")
    assert state_of(tasks, task) == "working"
    event("stop")
    assert state_of(tasks, task) == "idle"
    event("session-end")
    assert state_of(tasks, task) == "resume"


def test_unchanged_state_writes_nothing(tasks, stateful, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    event("session-start", cwd=str(repo))
    event("user-prompt-submit")
    tasks.invalidate()
    modified = tasks.get(task["uuid"])["modified"]
    event("user-prompt-submit")
    event("post-tool-use", tool_name="Read")
    tasks.invalidate()
    assert tasks.get(task["uuid"])["modified"] == modified


def test_two_sessions_on_one_task(tasks, stateful, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    event("session-start", "a", cwd=str(repo))
    event("session-start", "b", cwd=str(repo))
    event("user-prompt-submit", "a")
    assert state_of(tasks, task) == "working"
    event("session-end", "a")
    assert state_of(tasks, task) == "idle"


def test_a_crashed_agent_is_reaped(tasks, stateful, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    event("session-start", cwd=str(repo))
    agent = state.read_agent("s1")
    state.write_agent("s1", {**agent, "pid": 2**22 + 12345})
    state.reap()
    tasks.invalidate()
    state.refresh(tasks)
    assert state_of(tasks, task) == "resume"


def test_a_session_with_no_task_is_offered_one(tasks, stateful, repo, capsys):
    (repo / ".git" / "HEAD").write_text("ref: refs/heads/no-issue-here\n")
    event("session-start", cwd=str(repo), source="startup")
    offered = json.loads(capsys.readouterr().out)
    assert "wk adopt" in offered["hookSpecificOutput"]["additionalContext"]
    assert state.agents() == {}
    event("post-tool-use", tool_name="Read")  # and costs nothing afterwards
    assert state.agents() == {}


def test_adopt_ties_the_directory_and_session_to_a_new_task(tasks, stateful, repo, monkeypatch, capsys):
    (repo / ".git" / "HEAD").write_text("ref: refs/heads/tinkering\n")
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s9")
    assert cli.main(["adopt", "Tidy the prompt", "-C", str(repo)]) == 0
    tasks.invalidate()
    task = tasks.by_worktree(str(repo))
    assert task["description"] == "Tidy the prompt"
    assert task["session"] == "s9"
    assert task["state"] == "working"
    assert cli.main(["adopt", "again", "-C", str(repo)]) == 1


def test_hooks_never_fail(stateful, monkeypatch, capsys):
    import io

    monkeypatch.setattr("sys.stdin", io.StringIO("not json"))
    assert hooks.main(["claude", "stop"]) == 0
    assert hooks.main(["nonsense"]) == 0
