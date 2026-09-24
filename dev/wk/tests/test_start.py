import json
import os
import subprocess

from conftest import needs_task, needs_tmux
from test_open import app, git, option, wk  # noqa: F401  (fixtures)

from wk import workspace

pytestmark = [needs_task, needs_tmux]


def test_start_strings_the_steps_together(wk, tasks, app, tmux_server, world, capsys):  # noqa: F811
    (world / "config.toml").open("a").write('[start]\nprompt = "/lg"\n')
    # A stand-in for claude, so the window does not depend on the real one.
    (world / "bin").mkdir()
    (world / "bin" / "claude").write_text("#!/bin/sh\nsleep 30\n")
    (world / "bin" / "claude").chmod(0o755)
    path = f"{world / 'bin'}:{os.environ['PATH']}"
    subprocess.run(tmux_server + ["set-environment", "-g", "PATH", path], check=True)
    task = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})

    assert wk("start", "--no-switch", "--json", "ACME-12") == 0
    payload = json.loads(capsys.readouterr().out)
    task = tasks.get(task["uuid"])
    assert payload["claude"] is True
    assert payload["note"].endswith("ACME-12 Fix the thing.md")
    assert task["note"] and task["worktree"] and task["session"]
    assert task["start"], "kicking off starts the task"
    window = next(w for w in workspace.tmux.windows() if w["task"] == task["uuid"])
    command = option(tmux_server, window["id"], "pane_start_command")
    assert command.strip('"') == f"claude --session-id {task['session']} /lg"


def test_start_new_is_untracked_work_in_the_main_checkout(wk, tasks, app, tmux_server):  # noqa: F811
    assert wk("start", "--new", "Tidy the prompt", "--no-claude", "--no-switch", "-C", str(app)) == 0
    task = next(t for t in tasks.all() if t["description"] == "Tidy the prompt")
    assert task["repo"] == "acme/app" and task["project"] == "work"
    assert "branch" not in task and task["worktree"] == str(app)
    window = next(w for w in workspace.tmux.windows() if w["task"] == task["uuid"])
    assert window["session"] == "app"
    assert option(tmux_server, window["id"], "pane_current_path") == str(app)


def test_partof_links_a_sub_issue_to_its_parent(wk, tasks, app, tmux_server):  # noqa: F811
    parent = tasks.add("Investigate", {"issue": "ACME-1", "project": "work"})
    child = tasks.add("One part", {"issue": "ACME-2", "project": "work"})
    assert wk("start", "ACME-2", "--partof", "ACME-1", "--no-claude", "--no-switch") == 0
    assert tasks.get(child["uuid"])["partof"] == parent["uuid"]


def test_menu_lists_only_what_applies(wk, tasks, app, tmux_server, capsys):  # noqa: F811
    todo = tasks.add("Write the agenda")
    work = tasks.add("Fix", {"issue": "ACME-12", "prs": "#7,#8", "repo": "acme/app", "session": "abc"})
    review = tasks.add("Their PR", {"prs": "#9", "repo": "acme/app", "action": "review"})

    def actions(task):
        assert wk("menu", "--list", "--json", task["uuid"]) == 0
        return json.loads(capsys.readouterr().out)["actions"]

    assert actions(todo) == ["open in tmux", "note", "start: note, window and Claude", "sync now"]
    listed = actions(work)
    assert sum(a.startswith("open PR") for a in listed) == 2
    assert sum(a.startswith("merge PR") for a in listed) == 2
    assert "open issue ACME-12" in listed and "resume Claude session" in listed
    assert actions(review)[0] == "check out for review"
    assert not any(a.startswith(("merge PR", "start")) for a in actions(review))
    assert any(a.startswith("open PR   #9  review") for a in actions(review))
    assert any(a.startswith("open PR   #7  assign") for a in actions(work))


def test_background_names_the_branch_and_ties_the_session(wk, tasks, app, tmux_server, monkeypatch, capsys):  # noqa: F811
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "orchestrator")
    parent = tasks.add("Investigate", {"issue": "ACME-1", "project": "work"})
    child = tasks.add("One part", {"issue": "ACME-2", "project": "work"})
    windows = workspace.tmux.windows()
    assert wk("start", "ACME-2", "--partof", "ACME-1", "--background", "--json") == 0
    payload = json.loads(capsys.readouterr().out)
    child = tasks.get(child["uuid"])
    assert payload["branch"] == child["branch"] == "me/acme-2-one-part"
    assert payload["repository"] == str(app)
    assert payload["note"].endswith("ACME-2 One part.md")
    assert (child["session"], child["partof"], child["repo"]) == ("orchestrator", parent["uuid"], "acme/app")
    assert child["start"] and "worktree" not in child
    assert workspace.tmux.windows() == windows
    assert not (app / ".worktrees").exists()
