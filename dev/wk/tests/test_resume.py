import json
import os
import subprocess

from conftest import needs_task, needs_tmux
from test_open import app, git, option, wk  # noqa: F401  (fixtures)

from wk import resume, state, tmux

pytestmark = [needs_task, needs_tmux]


def stand_in(world, name="claude"):
    """A stand-in launcher in the server's PATH, so no window runs the real one."""
    (world / "bin" / name).write_text("#!/bin/sh\nsleep 30\n")
    (world / "bin" / name).chmod(0o755)


def transcript(world, session_id):
    """What `claude --resume` needs: the session's transcript on disk."""
    projects = world / ".claude" / "projects" / "-somewhere"
    projects.mkdir(parents=True, exist_ok=True)
    (projects / f"{session_id}.jsonl").write_text("{}\n")


def open_with_claude(wk, tasks, task, session_id):  # noqa: F811
    """The task's window with a Claude session recorded as live in its pane."""
    assert wk("open", "--no-switch", task["uuid"]) == 0
    window = next(w for w in tmux.windows() if w["task"] == task["uuid"])
    pane = tmux.panes(window["id"])[0]["id"]
    state.write_agent(session_id, {"uuid": task["uuid"], "pane": pane, "status": "idle", "pid": os.getpid()})
    return window


def test_snapshot_records_task_windows_and_their_claude(wk, tasks, app, tmux_server, world, capsys):  # noqa: F811
    stand_in(world)
    work = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    todo = tasks.add("Write the agenda", {"project": "work", "worktree": str(world)})
    open_with_claude(wk, tasks, work, "sess-work")
    assert wk("open", "--no-switch", todo["uuid"]) == 0
    subprocess.run(tmux_server + ["new-window", "-d", "-n", "scratch"], check=True)  # tied to nothing
    capsys.readouterr()

    assert wk("snapshot", "--json") == 0
    payload = json.loads(capsys.readouterr().out)
    by_task = {entry["task"]: entry for entry in payload["windows"]}
    assert set(by_task) == {work["uuid"], todo["uuid"]}
    assert by_task[work["uuid"]]["claude"] == "sess-work"
    assert by_task[work["uuid"]]["session"] == "app"
    assert by_task[work["uuid"]]["name"] == "ACME-12"
    assert by_task[work["uuid"]]["directory"] == tasks.get(work["uuid"])["worktree"]
    assert by_task[todo["uuid"]]["claude"] is None

    page = (world / ".local" / "state" / "wk" / "snapshot.md").read_text()
    assert f"cd {tasks.get(work['uuid'])['worktree']} && claude --resume sess-work" in page
    assert "no Claude session was running" in page


def test_resume_reopens_the_windows_with_claude_resumed(wk, tasks, app, tmux_server, world, capsys):  # noqa: F811
    stand_in(world)
    work = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    todo = tasks.add("Write the agenda", {"project": "work", "worktree": str(world)})
    closed = tasks.add("Done already", {"project": "work", "worktree": str(world)})
    window = open_with_claude(wk, tasks, work, "sess-work")
    subprocess.run(tmux_server + ["rename-window", "-t", window["id"], "renamed"], check=True)
    assert wk("open", "--no-switch", todo["uuid"]) == 0
    assert wk("open", "--no-switch", closed["uuid"]) == 0
    assert wk("snapshot") == 0
    transcript(world, "sess-work")

    # The reboot: windows and agents gone, one task finished meanwhile.
    for w in tmux.windows():
        if w["task"]:
            subprocess.run(tmux_server + ["kill-window", "-t", w["id"]], check=True)
    state.remove_agent("sess-work")
    tasks.done(tasks.get(closed["uuid"]))
    capsys.readouterr()

    assert wk("resume", "--dry-run", "--json") == 0
    outcomes = {r["task"]: r["outcome"] for r in json.loads(capsys.readouterr().out)["windows"]}
    assert outcomes == {work["uuid"]: "would open", todo["uuid"]: "would open", closed["uuid"]: "skipped"}
    assert not [w for w in tmux.windows() if w["task"]]

    assert wk("resume", "--json") == 0
    results = {r["task"]: r for r in json.loads(capsys.readouterr().out)["windows"]}
    assert results[work["uuid"]]["outcome"] == "opened" and results[work["uuid"]]["resumed"] is True
    assert results[todo["uuid"]]["outcome"] == "opened" and results[todo["uuid"]]["resumed"] is False
    assert results[closed["uuid"]]["why"] == "task closed"
    reopened = next(w for w in tmux.windows() if w["task"] == work["uuid"])
    assert reopened["session"] == "app" and reopened["name"] == "renamed"
    assert option(tmux_server, reopened["id"], "pane_start_command").strip('"') == "claude --resume sess-work"
    assert option(tmux_server, reopened["id"], "pane_current_path") == tasks.get(work["uuid"])["worktree"]
    plain = next(w for w in tmux.windows() if w["task"] == todo["uuid"])
    assert option(tmux_server, plain["id"], "pane_start_command") == ""

    assert wk("resume", "--json") == 0
    again = {r["task"]: r for r in json.loads(capsys.readouterr().out)["windows"]}
    assert again[work["uuid"]]["why"] == "already open"


def test_resume_keeps_the_window_in_its_tmux_session(wk, tasks, app, tmux_server, world, capsys):  # noqa: F811
    """A window moved to a session of my own (not the repository's) goes back
    there, and a session whose transcript is gone opens without Claude."""
    stand_in(world)
    work = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    window = open_with_claude(wk, tasks, work, "sess-lost")
    subprocess.run(tmux_server + ["new-session", "-d", "-s", "mine"], check=True)
    subprocess.run(tmux_server + ["move-window", "-s", window["id"], "-t", "mine:"], check=True)
    assert wk("snapshot") == 0
    subprocess.run(tmux_server + ["kill-session", "-t", "mine"], check=True)
    state.remove_agent("sess-lost")
    capsys.readouterr()

    assert wk("resume", "--json") == 0
    result = json.loads(capsys.readouterr().out)["windows"][0]
    assert result["outcome"] == "opened" and result["resumed"] is False
    assert "no transcript" in result["why"]
    reopened = next(w for w in tmux.windows() if w["task"] == work["uuid"])
    assert reopened["session"] == "mine"


def test_resume_without_a_snapshot_says_so(wk, world, capsys):  # noqa: F811
    assert wk("resume") != 0
    assert "wk snapshot" in capsys.readouterr().err


def test_start_runs_claude_through_the_configured_launcher(wk, tasks, app, tmux_server, world, capsys):  # noqa: F811
    (world / "config.toml").open("a").write('[start]\nclaude = "claude_vim"\n')
    stand_in(world, "claude_vim")
    task = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    assert wk("start", "--no-switch", "--json", task["uuid"]) == 0
    capsys.readouterr()
    window = next(w for w in tmux.windows() if w["task"] == task["uuid"])
    command = option(tmux_server, window["id"], "pane_start_command").strip('"')
    assert command == f"claude_vim --session-id {tasks.get(task['uuid'])['session']}"


def test_markdown_lists_every_window_with_its_command():
    snapshot = {
        "taken": "2026-10-05T22:00:00+02:00",
        "launcher": ["claude_vim"],
        "windows": [
            {
                "session": "app",
                "index": 1,
                "name": "ACME-12",
                "task": "u1",
                "id": 3,
                "description": "Fix the thing",
                "issue": "ACME-12",
                "directory": "/w/app/.worktrees/acme-12",
                "claude": "s1",
                "others": ["s2"],
                "claude_task": "u9",
            },
            {
                "session": "os",
                "index": 1,
                "name": "plan",
                "task": "u2",
                "id": 4,
                "description": "Plan it",
                "issue": "",
                "directory": "/home/me/os",
                "claude": None,
                "others": [],
                "last": "s3",
            },
        ],
    }
    page = resume.markdown(snapshot)
    assert "## tmux session `app`" in page and "## tmux session `os`" in page
    assert "`cd /w/app/.worktrees/acme-12 && claude_vim --resume s1`" in page
    assert "adopted task `u9`" in page
    assert "also in the window: `claude_vim --resume s2`" in page
    assert "`cd /home/me/os`, no Claude session was running" in page
    assert "the task's last one: `claude_vim --resume s3`" in page
