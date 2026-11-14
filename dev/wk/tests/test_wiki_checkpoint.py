"""wiki_checkpoint (dotfiles topic ai/os), where it meets wk: committing into
a vault. wk's hook commits its archive moves through it, so its commit
contract is tested here, against a throwaway git vault."""

import os
import subprocess

import pytest
from conftest import TOPIC

SCRIPT = TOPIC.parent.parent / "ai" / "os" / "wiki_checkpoint.sh"
NOTE = "wiki/tasks/ACME-1 Note.md"
ARCHIVED = "wiki/tasks/archive/ACME-1 Note.md"


@pytest.fixture
def vault(world, monkeypatch):
    """A vault with a repository, wiki_checkpoint and wk on PATH, and git
    kept away from the owner's configuration."""
    bin_dir = world / "bin"
    bin_dir.mkdir(exist_ok=True)
    os.symlink(SCRIPT, bin_dir / "wiki_checkpoint")
    os.symlink(TOPIC / "bin" / "wk", bin_dir / "wk")
    monkeypatch.setenv("PATH", f"{bin_dir}:{os.environ['PATH']}")
    monkeypatch.setenv("XDG_STATE_HOME", str(world / "state"))
    for key, value in {
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_SYSTEM": "/dev/null",
        "GIT_AUTHOR_NAME": "t",
        "GIT_AUTHOR_EMAIL": "t@t",
        "GIT_COMMITTER_NAME": "t",
        "GIT_COMMITTER_EMAIL": "t@t",
    }.items():
        monkeypatch.setenv(key, value)
    monkeypatch.delenv("CLAUDE_CODE_SESSION_ID", raising=False)

    path = world / "vaults" / "acme"
    (path / "wiki" / "tasks" / "archive").mkdir(parents=True, exist_ok=True)
    (path / "CLAUDE.md").write_text("# schema\n")
    (path / NOTE).write_text("---\ntask: u1\nstatus: active\n---\n\n# ACME-1 Note\n")
    (path / "wiki" / "page.md").write_text("a page\n")
    git(path, "init", "-q", "-b", "main")
    git(path, "add", "-A")
    git(path, "commit", "-q", "-m", "init")
    return path


def git(vault, *args):
    return subprocess.run(["git", "-C", str(vault), *args], capture_output=True, text=True, check=True).stdout


def checkpoint(*args, message=None, cwd=None):
    return subprocess.run(
        ["wiki_checkpoint", *map(str, args)],
        input=message,
        capture_output=True,
        text=True,
        cwd=cwd,
        stdin=None if message is not None else subprocess.DEVNULL,
    )


def last_commit(vault):
    return git(vault, "log", "-1", "--format=%s", "--name-status").strip()


def test_a_bare_commit_says_how_to_call_it(vault):
    result = checkpoint("commit")
    assert result.returncode != 0
    assert "usage: wiki_checkpoint commit VAULT" in result.stderr


def test_a_vault_can_be_named(vault):
    (vault / "wiki/page.md").write_text("edited\n")
    result = checkpoint("commit", "acme", "--", "wiki/page.md", message="edit\n")
    assert result.returncode == 0, result.stderr
    assert last_commit(vault) == "edit\n\nM\twiki/page.md"


def test_the_message_can_come_from_a_file(vault, world):
    (vault / "wiki/page.md").write_text("edited\n")
    (world / "msg.txt").write_text("from a file\n")
    result = checkpoint("commit", vault, "-F", world / "msg.txt", "--", vault / "wiki/page.md")
    assert result.returncode == 0, result.stderr
    assert last_commit(vault).startswith("from a file\n")
