import datetime
import os

from conftest import needs_task

from wk import notes

pytestmark = needs_task

TODAY = datetime.date.today().isoformat()


def test_note_is_created_in_the_projects_vault_and_cached_on_the_task(config, tasks, world):
    task = tasks.add("Fix: the thing/that broke", {"issue": "ACME-9", "project": "work.backend"})
    path = notes.ensure(config, tasks, task)

    assert path == str(world / "vaults/acme/wiki/tasks/ACME-9 Fix- the thing-that broke.md")
    text = open(path).read()
    assert text.startswith(f"---\ntask: {task['uuid']}\nissue: ACME-9\nproject: work.backend\ncreated: {TODAY}\n")
    assert "\n# ACME-9 Fix- the thing-that broke\n" in text
    assert "- [ ] \n" in text

    task = tasks.get(task["uuid"])
    assert task["note"] == "wiki/tasks/ACME-9 Fix- the thing-that broke"
    assert task["note_flag"] == config.note_flag


def test_without_an_issue_the_date_leads_and_the_first_existing_subdir_wins(config, tasks, world):
    task = tasks.add("Tinker with the prompt")
    path = notes.ensure(config, tasks, task)
    assert path == str(world / f"vaults/personal/tasks/{TODAY} Tinker with the prompt.md")


def test_issue_key_is_picked_out_of_the_description(config, tasks):
    task = tasks.add("ACME-44: tidy up", {"project": "work"})
    path = notes.ensure(config, tasks, task)
    assert os.path.basename(path) == "ACME-44 tidy up.md"
    assert "issue: ACME-44" in open(path).read()


def test_a_second_call_finds_the_same_note(config, tasks):
    task = tasks.add("same", {"issue": "ACME-1", "project": "work"})
    first = notes.ensure(config, tasks, task)
    assert notes.ensure(config, tasks, tasks.get(task["uuid"])) == first


def test_name_collisions_get_a_suffix(config, tasks):
    one = notes.ensure(config, tasks, tasks.add("twin", {"issue": "ACME-2", "project": "work"}))
    tasks._task([tasks.by_issue("ACME-2")["uuid"], "done"])
    tasks.invalidate()
    two = notes.ensure(config, tasks, tasks.add("twin", {"issue": "ACME-2", "project": "work"}))
    assert one != two
    assert two.endswith("ACME-2 twin (2).md")


def test_a_note_renamed_in_obsidian_is_recovered_by_uuid(config, tasks):
    task = tasks.add("rename me", {"issue": "ACME-3", "project": "work"})
    path = notes.ensure(config, tasks, task)
    renamed = os.path.join(os.path.dirname(path), "Better name.md")
    os.rename(path, renamed)

    assert notes.ensure(config, tasks, tasks.get(task["uuid"])) == renamed
    assert tasks.get(task["uuid"])["note"] == "wiki/tasks/Better name"


def test_a_uuid_in_the_body_is_not_a_link(config, tasks, world):
    task = tasks.add("decoy", {"project": "work"})
    decoy = world / "vaults/acme/wiki/tasks/decoy.md"
    decoy.write_text(f"---\ntask: someone-else\n---\n\ntask: {task['uuid']}\n")
    assert notes.ensure(config, tasks, task, create_missing=False) is None


def test_closing_archives_and_reopening_restores(config, tasks, world):
    task = tasks.add("archive me", {"issue": "ACME-4", "project": "work"})
    path = notes.ensure(config, tasks, task)
    task = tasks.get(task["uuid"])

    moved = notes.move_for_status(config, task, closed=True)
    assert moved == "wiki/tasks/archive/ACME-4 archive me"
    archived = world / "vaults/acme" / (moved + ".md")
    assert not os.path.exists(path)
    assert f"status: done\nclosed: {TODAY}\n---" in archived.read_text()

    # The cached path is stale now, as it is after `task undo`: found by uuid.
    assert notes.move_for_status(config, task, closed=False) == "wiki/tasks/ACME-4 archive me"
    assert "status: active" in open(path).read()


def test_frontmatter_edits_leave_the_body_alone(tmp_path):
    note = tmp_path / "n.md"
    note.write_text("---\ntask: x\nstatus: active\n---\n\nstatus: in the body\n")
    notes.set_frontmatter(str(note), {"status": "done", "closed": "2026-01-01"})
    assert note.read_text() == "---\ntask: x\nstatus: done\nclosed: 2026-01-01\n---\n\nstatus: in the body\n"


def test_no_note_nothing_to_move(config, tasks):
    assert notes.move_for_status(config, tasks.add("noteless"), closed=True) is None
