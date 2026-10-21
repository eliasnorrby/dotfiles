import os

from wk import git


def test_the_agent_socket_is_found_in_the_runtime_dir(tmp_path, monkeypatch):
    sock = tmp_path / "ssh-agent.socket"
    sock.touch()
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.delenv("SSH_AUTH_SOCK", raising=False)
    assert git.environment()["SSH_AUTH_SOCK"] == str(sock)
    assert git.environment()["GIT_TERMINAL_PROMPT"] == "0"


def test_an_agent_already_in_the_environment_wins(tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.setenv("SSH_AUTH_SOCK", "/elsewhere")
    assert git.environment()["SSH_AUTH_SOCK"] == "/elsewhere"


def test_a_missing_socket_is_ignored(tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.delenv("SSH_AUTH_SOCK", raising=False)
    assert "SSH_AUTH_SOCK" not in git.environment()
    assert os.environ.get("SSH_AUTH_SOCK") is None
