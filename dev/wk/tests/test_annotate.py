import subprocess

from conftest import needs_task, needs_tmux

from wk import cli
from wk.errors import Unreachable

pytestmark = [needs_task, needs_tmux]


def option(server, target, name):
    command = server + ["display-message", "-p", "-t", target, f"#{{{name}}}"]
    return subprocess.run(command, capture_output=True, text=True, check=True).stdout.strip()


def test_annotate_ties_the_window_to_the_task(tasks, tmux_server):
    task = tasks.add("Fix the thing", {"issue": "ACME-12"})
    assert cli.main(["annotate", "-t", "main:0", "ACME-12"]) == 0
    assert option(tmux_server, "main:0", "@task") == task["uuid"]
    assert option(tmux_server, "main:0", "@issue") == "ACME-12"
    assert option(tmux_server, "main:0", "@desc") == "Fix the thing"
    assert option(tmux_server, "main:0", "window_name") == "ACME-12"


def test_a_useless_clipboard_falls_back_to_the_windows_checkout(tasks, repo, tmux_server, monkeypatch):
    def unreachable(_key):
        raise Unreachable("no network")

    monkeypatch.setattr("wk.trackers.linear.fetch_issue", unreachable)
    monkeypatch.setattr("wk.platform.read_clipboard", lambda: "some words, not a reference")
    assert cli.main(["annotate", "-t", "main:0", "-C", str(repo), "--from", "clipboard"]) == 0
    imported = tasks.by_issue("ACME-12")
    assert option(tmux_server, "main:0", "@task") == imported["uuid"]


def test_nothing_to_annotate_with(tasks, world, tmux_server):
    assert cli.main(["annotate", "-t", "main:0", "-C", str(world)]) == 2
    assert option(tmux_server, "main:0", "@task") == ""
