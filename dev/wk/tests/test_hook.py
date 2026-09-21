import json
import os
import subprocess
import sys

from conftest import TOPIC, needs_task

from wk import notes

HOOK = TOPIC / "hooks" / "on-modify-wk"


def run_hook(stdin):
    return subprocess.run([sys.executable, str(HOOK)], input=stdin, capture_output=True, text=True)


def test_malformed_input_hands_back_the_modified_line(world):
    result = run_hook("not json\nalso not json\n")
    assert result.returncode == 0
    assert result.stdout == "also not json\n"


def test_a_missing_second_line_hands_back_the_original(world):
    assert run_hook('{"uuid":"x"}\n').stdout == '{"uuid":"x"}\n'


def test_an_ordinary_edit_passes_through_untouched(world):
    before = json.dumps({"uuid": "u", "status": "pending", "description": "a"})
    after = json.dumps({"uuid": "u", "status": "pending", "description": "b"})
    assert run_hook(f"{before}\n{after}\n").stdout == after + "\n"


def test_a_broken_config_never_blocks_a_modification(world):
    (world / "config.toml").write_text("[defaults\n")
    before = json.dumps({"uuid": "u", "status": "pending"})
    after = json.dumps({"uuid": "u", "status": "completed"})
    assert run_hook(f"{before}\n{after}\n").stdout == after + "\n"


@needs_task
def test_done_archives_the_note_through_taskwarrior_itself(config, tasks, world):
    hooks = world / "taskdata" / "hooks"
    hooks.mkdir()
    os.symlink(HOOK, hooks / "on-modify.wk")

    task = tasks.add("archive me", {"issue": "ACME-4", "project": "work"})
    path = notes.ensure(config, tasks, task)
    tasks._task([task["uuid"], "done"])
    tasks.invalidate()

    done = tasks.get(task["uuid"])
    assert done["status"] == "completed"
    assert done["note"] == "wiki/tasks/archive/ACME-4 archive me"
    assert not os.path.exists(path)
    assert (world / "vaults/acme/wiki/tasks/archive/ACME-4 archive me.md").exists()

    tasks._task([task["uuid"], "modify", "status:pending"])
    tasks.invalidate()
    assert tasks.get(task["uuid"])["note"] == "wiki/tasks/ACME-4 archive me"
    assert os.path.exists(path)
