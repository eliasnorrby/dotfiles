import os

from wk import git


def test_the_agent_socket_is_read_from_the_shells_env_file(tmp_path, monkeypatch):
    sock = tmp_path / "agent.sock"
    sock.touch()
    (tmp_path / "ssh-agent.env").write_text(
        f"SSH_AUTH_SOCK={sock}; export SSH_AUTH_SOCK;\nSSH_AGENT_PID=1; export SSH_AGENT_PID;\n"
    )
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.delenv("SSH_AUTH_SOCK", raising=False)
    assert git.environment()["SSH_AUTH_SOCK"] == str(sock)
    assert git.environment()["GIT_TERMINAL_PROMPT"] == "0"


def test_an_agent_already_in_the_environment_wins(tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.setenv("SSH_AUTH_SOCK", "/elsewhere")
    assert git.environment()["SSH_AUTH_SOCK"] == "/elsewhere"


def test_a_stale_socket_is_ignored(tmp_path, monkeypatch):
    (tmp_path / "ssh-agent.env").write_text(f"SSH_AUTH_SOCK={tmp_path}/gone; export SSH_AUTH_SOCK;\n")
    monkeypatch.setenv("XDG_RUNTIME_DIR", str(tmp_path))
    monkeypatch.delenv("SSH_AUTH_SOCK", raising=False)
    assert "SSH_AUTH_SOCK" not in git.environment()
    assert os.environ.get("SSH_AUTH_SOCK") is None
