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
