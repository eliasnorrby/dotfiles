import pytest

from wk.config import Config
from wk.errors import NotFound, WkError


def test_defaults_without_a_file(tmp_path):
    config = Config.load(tmp_path / "missing.toml")
    assert config.vault_for_project("anything") == "personal"
    assert config.note_subdirs == ["wiki/tasks", "tasks"]


def test_get_walks_tables_whose_keys_contain_slashes_and_dots():
    config = Config({"repos": {"acme/app": {"path": "~/x"}, "acme/app.js": {"path": "~/y"}}})
    assert config.get("repos.acme/app.path") == "~/x"
    assert config.get("repos.acme/app.js.path") == "~/y"
    with pytest.raises(NotFound):
        config.get("repos.nope.path")


def test_vault_follows_the_project_root(config):
    assert config.vault_for_project("work.backend") == "acme"
    assert config.vault_for_project("dotfiles") == "personal"
    assert config.vault_for_project(None) == "personal"


def test_team_lookup_is_case_insensitive(config):
    assert config.project_for_issue("acme-5") == "work"
    assert config.project_for_issue("OTHER-5") == "inbox"


def test_a_broken_file_is_reported(tmp_path):
    path = tmp_path / "config.toml"
    path.write_text("[defaults\n")
    with pytest.raises(WkError):
        Config.load(path)


def test_merge_strategy_is_per_repo_with_a_default():
    assert Config().merge_flags("acme/app") == []  # gh asks
    config = Config(
        {"defaults": {"merge": "squash"}, "repos": {"acme/app": {"merge": "rebase"}, "acme/ask": {"merge": ""}}}
    )
    assert config.merge_flags("acme/app") == ["--rebase"]
    assert config.merge_flags("acme/other") == ["--squash"]
    assert config.merge_flags("acme/ask") == []
    with pytest.raises(WkError):
        Config({"defaults": {"merge": "fast-forward"}}).merge_flags("acme/app")
