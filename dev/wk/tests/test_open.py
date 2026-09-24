import os
import subprocess

import pytest
from conftest import needs_task, needs_tmux

from wk import cli, workspace
from wk.errors import Unreachable

pytestmark = [needs_task, needs_tmux]

GIT_ENV = {"GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"}


def git(cwd, *args):
    env = {**os.environ, **GIT_ENV}
    identity = ["-c", "user.name=t", "-c", "user.email=t@t"]
    return subprocess.run(["git", *identity, *args], cwd=cwd, check=True, env=env, capture_output=True, text=True)


@pytest.fixture
def app(world, monkeypatch):
    """acme/app: a bare origin, and a main checkout wk's config points at."""
    origin = world / "acme" / "app.git"  # so the remote reads as acme/app
    origin.parent.mkdir()
    git(world, "init", "-q", "--bare", "-b", "main", str(origin))
    main = world / "app"
    git(world, "clone", "-q", str(origin), str(main))
    git(main, "commit", "-q", "--allow-empty", "-m", "init")
    git(main, "push", "-q", "origin", "HEAD:main")
    git(main, "remote", "set-head", "origin", "main")
    (world / "config.toml").open("a").write(f'path = "{main}"\nsession = "app"\n')
    for name, value in GIT_ENV.items():
        monkeypatch.setenv(name, value)
    monkeypatch.setenv("USER", "me")

    def unreachable(_key):
        raise Unreachable("no network")

    monkeypatch.setattr("wk.trackers.linear.fetch_issue", unreachable)
    return main


@pytest.fixture
def wk(tasks):
    """Run the CLI, which has its own view of taskwarrior; drop ours after."""

    def run(*argv):
        code = cli.main(list(argv))
        tasks.invalidate()
        return code

    return run


def option(server, target, name):
    command = server + ["display-message", "-p", "-t", target, f"#{{{name}}}"]
    return subprocess.run(command, capture_output=True, text=True, check=True).stdout.strip()


def test_the_whole_ladder_from_a_bare_issue_task(wk, tasks, app, tmux_server):
    task = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    assert wk("open", "--no-switch", task["uuid"]) == 0

    task = tasks.get(task["uuid"])
    assert task["branch"] == "me/acme-12-fix-the-thing"
    assert task["worktree"] == str(app / ".worktrees" / "acme-12")
    assert task["repo"] == "acme/app"
    assert git(task["worktree"], "branch", "--show-current").stdout.strip() == "me/acme-12-fix-the-thing"

    window = next(w for w in workspace.tmux.windows() if w["task"] == task["uuid"])
    assert window["session"] == "app"
    assert window["worktree"] == task["worktree"]
    assert option(tmux_server, window["id"], "window_name") == "ACME-12"
    assert option(tmux_server, window["id"], "@desc") == "Fix the thing"
    assert option(tmux_server, window["id"], "pane_current_path") == task["worktree"]


def test_opening_again_finds_the_same_window(wk, tasks, app, tmux_server):
    task = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    wk("open", "--no-switch", task["uuid"])
    before = workspace.tmux.windows()
    wk("open", "--no-switch", "ACME-12")
    assert workspace.tmux.windows() == before


def test_an_existing_remote_branch_is_tracked_not_recreated(wk, tasks, app, tmux_server):
    git(app, "push", "-q", "origin", "HEAD:refs/heads/them/feature")
    task = tasks.add("their feature", {"branch": "them/feature", "repo": "acme/app"})
    wk("open", "--no-switch", task["uuid"])
    worktree = tasks.get(task["uuid"])["worktree"]
    assert worktree == str(app / ".worktrees" / "feature")
    assert git(worktree, "rev-parse", "--abbrev-ref", "@{upstream}").stdout.strip() == "origin/them/feature"


def test_a_window_already_on_the_checkout_is_used_but_not_taken_over(wk, tasks, app, tmux_server):
    parent = tasks.add("the investigation", {"issue": "ACME-1", "project": "work"})
    wk("open", "--no-switch", parent["uuid"])
    directory = tasks.get(parent["uuid"])["worktree"]
    # The parent's agent switches its checkout to the sub-issue's branch.
    git(directory, "checkout", "-q", "-b", "me/acme-2-one-part")
    child = tasks.add("one part", {"issue": "ACME-2", "project": "work", "branch": "me/acme-2-one-part"})

    windows = workspace.tmux.windows()
    assert wk("open", "--no-switch", child["uuid"]) == 0
    assert workspace.tmux.windows() == windows
    assert tasks.get(child["uuid"])["worktree"] == directory
    assert [w["task"] for w in windows if w["worktree"] == directory] == [parent["uuid"]]


def test_a_plain_todo_gets_a_window_and_nothing_else(wk, tasks, app, tmux_server, world):
    task = tasks.add("Write the agenda", {"project": "work"})
    assert wk("open", "--no-switch", task["uuid"]) == 0
    task = tasks.get(task["uuid"])
    assert "branch" not in task
    window = next(w for w in workspace.tmux.windows() if w["task"] == task["uuid"])
    assert window["session"] == "main"
    assert not (app / ".worktrees").exists()


def test_a_task_opens_in_its_own_directory(wk, tasks, app, tmux_server, world):
    vault = world / "vaults" / "acme"
    task = tasks.add("Backfill the wiki", {"project": "work", "worktree": str(vault)})
    assert wk("open", "--no-switch", task["uuid"]) == 0
    window = next(w for w in workspace.tmux.windows() if w["task"] == task["uuid"])
    assert option(tmux_server, window["id"], "pane_current_path") == str(vault)
    assert "branch" not in tasks.get(task["uuid"])


def test_in_records_the_directory_and_the_project_supplies_a_default(wk, tasks, app, tmux_server, world):
    (world / "config.toml").open("a").write(f'[projects.tools]\ndir = "{world}"\n')
    by_flag = tasks.add("Tinker", {"project": "tools"})
    assert wk("open", "--no-switch", "--in", str(app), by_flag["uuid"]) == 0
    assert tasks.get(by_flag["uuid"])["worktree"] == str(app)
    assert tasks.get(by_flag["uuid"])["repo"] == "acme/app"
    by_project = tasks.add("Tinker more", {"project": "tools"})
    assert wk("open", "--no-switch", by_project["uuid"]) == 0
    assert tasks.get(by_project["uuid"])["worktree"] == str(world)


def test_a_branch_from_the_clipboard_becomes_a_task(wk, tasks, app, tmux_server, monkeypatch):
    monkeypatch.setattr("wk.platform.read_clipboard", lambda: "me/try-something")
    assert wk("open", "--no-switch", "--from", "clipboard", "-C", str(app)) == 0
    task = tasks.by_branch("me/try-something")
    assert task["description"] == "try something"
    assert task["repo"] == "acme/app"
    assert task["worktree"] == str(app / ".worktrees" / "try-something")


def test_a_clipboard_full_of_something_else_is_not_a_branch(wk, tasks, app, tmux_server, monkeypatch):
    monkeypatch.setattr("wk.platform.read_clipboard", lambda: "someword")
    assert wk("open", "--no-switch", "--from", "clipboard", "-C", str(app)) == 2
    assert tasks.all() == []


def test_switching_moves_an_attached_client(wk, tasks, app, tmux_server, monkeypatch):
    import pty
    import time

    task = tasks.add("Fix the thing", {"issue": "ACME-12", "project": "work"})
    pid, _fd = pty.fork()
    if pid == 0:
        os.execvp(tmux_server[0], tmux_server + ["attach", "-t", "main"])
    try:
        for _ in range(50):
            if workspace.tmux.clients():
                break
            time.sleep(0.1)
        monkeypatch.setattr("wk.platform.focus_terminal", lambda pid: None)
        assert wk("open", task["uuid"]) == 0
        assert workspace.tmux.clients()[0]["session"] == "app"
    finally:
        os.kill(pid, 15)
        os.waitpid(pid, 0)


def test_a_task_without_a_window_opens_where_its_session_runs(wk, tasks, app, tmux_server, world, monkeypatch):
    from wk import state

    monkeypatch.setenv("XDG_STATE_HOME", str(world / "state"))
    parent = tasks.add("the investigation", {"issue": "ACME-1", "project": "work"})
    wk("open", "--no-switch", parent["uuid"])
    window = next(w for w in workspace.tmux.windows() if w["task"] == parent["uuid"])
    pane = option(tmux_server, window["id"], "pane_id")
    state.write_agent("orchestrator", {"uuid": parent["uuid"], "pane": pane, "pid": os.getpid()})
    child = tasks.add("one part", {"issue": "ACME-2", "project": "work", "session": "orchestrator"})

    windows = workspace.tmux.windows()
    assert wk("open", "--no-switch", child["uuid"]) == 0
    assert workspace.tmux.windows() == windows
    assert "worktree" not in tasks.get(child["uuid"])

    state.remove_agent("orchestrator")  # the session is gone: the task gets a window of its own
    assert wk("open", "--no-switch", child["uuid"]) == 0
    assert tasks.get(child["uuid"])["worktree"] == str(app / ".worktrees" / "acme-2")
