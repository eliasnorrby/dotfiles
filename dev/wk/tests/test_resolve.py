import subprocess
import time

from conftest import needs_task, needs_tmux

from wk.locator import Locator, parse
from wk.resolve import resolve

pytestmark = needs_task


def test_the_branchs_issue_key_finds_the_task(tasks, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task["uuid"] == task["uuid"]
    assert resolution.how == "issue"


def test_no_task_yet_still_names_what_could_be_imported(tasks, repo):
    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task is None
    assert resolution.reference == Locator("issue", "ACME-12")
    assert resolution.issue == "ACME-12"
    assert resolution.branch == "someone/acme-12-fix-the-thing"


def test_a_recorded_branch_beats_the_key_it_carries(tasks, repo):
    tasks.add("by key", {"issue": "ACME-12"})
    by_branch = tasks.add("by branch", {"branch": "someone/acme-12-fix-the-thing"})
    assert resolve(tasks, cwd=str(repo)).task["uuid"] == by_branch["uuid"]


def test_a_recorded_worktree_beats_the_branch(tasks, repo):
    tasks.add("by key", {"issue": "ACME-12"})
    untracked = tasks.add("untracked work", {"worktree": str(repo)})
    nested = repo / "src"
    nested.mkdir()
    resolution = resolve(tasks, cwd=str(nested))
    assert resolution.task["uuid"] == untracked["uuid"]
    assert resolution.how == "worktree"


def test_nothing_to_go_on(tasks, world):
    resolution = resolve(tasks, cwd=str(world))
    assert resolution.task is None and resolution.reference is None


def test_explicit_locators(tasks, repo):
    task = tasks.add("the thing", {"issue": "ACME-12"})
    assert resolve(tasks, parse(task["uuid"])).task["uuid"] == task["uuid"]
    assert resolve(tasks, parse(str(task["id"]))).task["uuid"] == task["uuid"]
    assert resolve(tasks, parse("acme-12")).task["uuid"] == task["uuid"]
    assert resolve(tasks, parse("someone/acme-12-other-branch")).task["uuid"] == task["uuid"]
    assert resolve(tasks, parse(str(repo))).task["uuid"] == task["uuid"]
    assert resolve(tasks, parse("ACME-13")).task is None


@needs_tmux
def test_the_windows_task_wins_over_the_directory(tasks, repo, tmux_server, monkeypatch):
    tasks.add("by key", {"issue": "ACME-12"})
    parent = tasks.add("the parent investigation")
    pane = subprocess.run(
        tmux_server + ["display-message", "-p", "-t", "main", "#{pane_id}"], capture_output=True, text=True, check=True
    ).stdout.strip()
    subprocess.run(tmux_server + ["set-option", "-w", "-t", "main", "@task", parent["uuid"]], check=True)
    monkeypatch.setenv("TMUX_PANE", pane)

    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task["uuid"] == parent["uuid"]
    assert resolution.how == "window"
    assert resolve(tasks, parse("main:0")).task["uuid"] == parent["uuid"]


@needs_tmux
def test_a_window_without_a_task_falls_back_to_its_directory(tasks, repo, tmux_server):
    task = tasks.add("by key", {"issue": "ACME-12"})
    subprocess.run(tmux_server + ["new-window", "-d", "-t", "main", "-n", "work", "-c", str(repo)], check=True)
    for _ in range(50):  # the pane's shell reports its directory once it is up
        if resolve(tasks, parse("main:work")).task:
            break
        time.sleep(0.1)
    assert resolve(tasks, parse("main:work")).task["uuid"] == task["uuid"]


def _share(world, path):
    (world / "config.toml").open("a").write(f'[projects.dotfiles]\ndir = "{path}"\n')


def test_the_claude_session_finds_its_task_outside_tmux_and_in_a_shared_root(tasks, repo, world, monkeypatch):
    """A shared root names no task by directory or branch; the session that
    adopted one still knows it."""
    _share(world, repo)
    adopted = tasks.add("Lazy ts_ls", {"worktree": str(repo), "branch": "main", "session": "s1"})
    assert resolve(tasks, cwd=str(repo)).task is None
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s1")
    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task["uuid"] == adopted["uuid"]
    assert resolution.how == "session"
    assert resolve(tasks, cwd=str(repo), session="s2").task is None


def test_a_closed_task_no_longer_answers_for_its_session(tasks, repo, world, monkeypatch):
    _share(world, repo)
    tasks.done(tasks.add("Finished", {"session": "s1"}))
    monkeypatch.setenv("CLAUDE_CODE_SESSION_ID", "s1")
    assert resolve(tasks, cwd=str(repo)).task is None


def test_the_window_comes_before_the_session(tasks, repo, monkeypatch):
    window = tasks.add("the window's")
    tasks.add("the session's", {"session": "s1"})
    monkeypatch.setattr("wk.tmux.current_task", lambda: window["uuid"])
    assert resolve(tasks, cwd=str(repo), session="s1").how == "window"


def test_a_session_on_several_tasks_picks_the_one_it_moved_to(world, monkeypatch):
    from wk import state
    from wk.tasks import Tasks

    monkeypatch.setenv("XDG_STATE_HOME", str(world / "state"))
    tasks = Tasks()
    tasks._all = [
        {"uuid": "a", "status": "pending", "session": "s1", "modified": "20261101T100000Z"},
        {"uuid": "b", "status": "pending", "session": "s1", "modified": "20261102T100000Z"},
        {"uuid": "c", "status": "completed", "session": "s1", "modified": "20261103T100000Z"},
    ]
    assert tasks.by_session("s1")["uuid"] == "b", "the most recently modified open one"
    state.write_agent("s1", {"uuid": "a"})
    assert resolve(tasks, cwd=str(world), session="s1").task["uuid"] == "a", "the one the session tied itself to"


def test_a_closed_task_claims_no_directory(tasks, repo):
    finished = tasks.add("finished here", {"worktree": str(repo), "branch": "someone/acme-12-fix-the-thing"})
    tasks.done(finished)
    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task is None
    assert resolution.reference == Locator("issue", "ACME-12")


def test_a_branch_name_only_counts_within_its_repository(tasks, repo):
    """Every repository has a main: a task on another's says nothing here."""
    subprocess.run(["git", "checkout", "-q", "main"], cwd=repo, check=True)
    subprocess.run(["git", "remote", "add", "origin", "git@github.com:acme/app.git"], cwd=repo, check=True)
    tasks.add("household export", {"branch": "main", "repo": "me/economy", "worktree": "/elsewhere"})
    assert resolve(tasks, cwd=str(repo)).task is None
    ours = tasks.add("ours", {"branch": "main", "repo": "acme/app"})
    resolution = resolve(tasks, cwd=str(repo))
    assert resolution.task["uuid"] == ours["uuid"]
    assert resolution.why == f"its branch main is checked out in {repo}"


def test_why_says_how_a_worktree_matched(tasks, repo):
    tasks.add("untracked work", {"worktree": str(repo)})
    nested = repo / "src"
    nested.mkdir()
    assert resolve(tasks, cwd=str(nested)).why == f"its worktree {repo} contains {nested}"
