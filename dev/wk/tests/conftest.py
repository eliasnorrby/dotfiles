"""Shared fixtures.

Nothing here may touch the real world: taskwarrior runs against a throwaway
TASKRC/TASKDATA (whose rc includes this topic's taskrc, so the schema is under
test as well), wk reads a throwaway config, and tmux, where used, runs on a
private socket. Never the default tmux server.
"""

import os
import shutil
import subprocess
import textwrap
from pathlib import Path

import pytest

TOPIC = Path(__file__).resolve().parent.parent


def _task_major():
    if not shutil.which("task"):
        return 0
    version = subprocess.run(["task", "--version"], capture_output=True, text=True).stdout
    return int(version.split(".")[0] or 0)


needs_task = pytest.mark.skipif(_task_major() < 3, reason="needs taskwarrior 3")
needs_tmux = pytest.mark.skipif(not shutil.which("tmux"), reason="needs tmux")


@pytest.fixture
def world(tmp_path, monkeypatch):
    """A self-contained home: taskwarrior data, vaults and wk config."""
    data = tmp_path / "taskdata"
    data.mkdir()
    taskrc = tmp_path / "taskrc"
    taskrc.write_text(f"data.location={data}\nconfirmation=off\ninclude {TOPIC / 'taskrc'}\n")
    vaults = tmp_path / "vaults"
    (vaults / "acme" / "wiki" / "tasks").mkdir(parents=True)
    (vaults / "personal" / "tasks").mkdir(parents=True)
    config = tmp_path / "config.toml"
    config.write_text(
        textwrap.dedent(f"""
            [defaults]
            vaults_dir = "{vaults}"
            [teams.ACME]
            project = "work"
            workspace = "acme"
            [projects.work]
            vault = "acme"
            [repos."acme/app"]
            project = "work"
        """)
    )
    monkeypatch.setenv("TASKRC", str(taskrc))
    monkeypatch.setenv("TASKDATA", str(data))
    monkeypatch.setenv("WK_CONFIG", str(config))
    monkeypatch.setenv("HOME", str(tmp_path))
    for name in ("TMUX", "TMUX_PANE", "WK_TMUX_SOCKET", "LINEAR_API_KEY", "XDG_CONFIG_HOME"):
        monkeypatch.delenv(name, raising=False)
    monkeypatch.chdir(tmp_path)
    return tmp_path


@pytest.fixture
def config(world):
    from wk.config import Config

    return Config.load()


@pytest.fixture
def tasks(world):
    from wk.tasks import Tasks

    return Tasks()


@pytest.fixture
def repo(world):
    """A git repository on an issue branch."""
    path = world / "repo"
    path.mkdir()
    env = {**os.environ, "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null"}
    for command in (
        ["git", "init", "-q", "-b", "main"],
        ["git", "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "--allow-empty", "-m", "init"],
        ["git", "checkout", "-q", "-b", "someone/acme-12-fix-the-thing"],
    ):
        subprocess.run(command, cwd=path, check=True, env=env)
    return path


@pytest.fixture
def tmux_server(monkeypatch, world):
    """A private tmux server. Never the default socket."""
    socket = f"wk-test-{os.getpid()}"
    base = ["tmux", "-L", socket, "-f", "/dev/null"]
    subprocess.run(base + ["new-session", "-d", "-s", "main", "-c", str(world)], check=True)
    monkeypatch.setenv("WK_TMUX_SOCKET", socket)
    yield base
    subprocess.run(base + ["kill-server"], capture_output=True)
