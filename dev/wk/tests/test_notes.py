import datetime
import os

import pytest
from conftest import needs_task

from wk import notes
from wk.errors import WkError

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


def test_a_project_id_is_not_an_issue_key(config, tasks, world):
    task = tasks.add("Read up on Project Solidarity (P-ACME-134)")
    path = notes.ensure(config, tasks, task)
    assert path == str(world / f"vaults/personal/tasks/{TODAY} Read up on Project Solidarity (P-ACME-134).md")
    assert "issue:" not in open(path).read()


def test_a_name_keeps_out_what_breaks_a_wikilink(config, tasks):
    task = tasks.add("Review the [stack] (from #11374) | ^x")
    path = notes.ensure(config, tasks, task)
    assert os.path.basename(path) == f"{TODAY} Review the stack (from 11374) - x.md"


def test_a_second_call_finds_the_same_note(config, tasks):
    task = tasks.add("same", {"issue": "ACME-1", "project": "work"})
    first = notes.ensure(config, tasks, task)
    assert notes.ensure(config, tasks, tasks.get(task["uuid"])) == first


def test_a_note_of_another_task_for_the_issue_is_named_not_duplicated(config, tasks, world):
    first = tasks.add("twin", {"issue": "ACME-2", "project": "work"})
    notes.ensure(config, tasks, first)
    tasks.done(tasks.get(first["uuid"]))
    second = tasks.add("twin, again", {"issue": "ACME-2", "project": "work"})

    with pytest.raises(WkError, match=rf"wiki/tasks/ACME-2 twin.md already stands for ACME-2.*{first['uuid']}"):
        notes.ensure(config, tasks, second)
    assert os.listdir(world / "vaults/acme/wiki/tasks") == ["ACME-2 twin.md"]


BACKFILLED = "---\ntype: task\nissue: ACME-20\nstatus: active\n---\n\n# ACME-20 Backfilled\n\nall of it\n"


def test_a_backfilled_note_for_the_issue_is_adopted(config, tasks, world):
    note = world / "vaults/acme/wiki/tasks/ACME-20 Backfilled.md"
    note.write_text(BACKFILLED)
    task = tasks.add("A different title", {"issue": "ACME-20", "project": "work"})

    assert notes.ensure(config, tasks, task) == str(note)
    assert note.read_text().startswith(f"---\ntype: task\nissue: ACME-20\nstatus: active\ntask: {task['uuid']}\n---")
    assert "all of it" in note.read_text()
    assert os.listdir(note.parent) == [note.name]
    assert tasks.get(task["uuid"])["note"] == "wiki/tasks/ACME-20 Backfilled"


def test_a_note_of_the_same_name_without_a_task_is_adopted(config, tasks, world):
    note = world / f"vaults/personal/tasks/{TODAY} Tinker.md"
    note.write_text("---\nstatus: active\n---\n\nbody\n")
    task = tasks.add("Tinker")
    assert notes.ensure(config, tasks, task) == str(note)
    assert f"task: {task['uuid']}" in note.read_text()


def test_an_archived_backfilled_note_is_brought_back_for_an_open_task(config, tasks, world):
    archive = world / "vaults/acme/wiki/tasks/archive"
    archive.mkdir()
    (archive / "ACME-21 Old.md").write_text("---\nissue: ACME-21\nstatus: done\nclosed: 2026-09-01\n---\n")
    task = tasks.add("Old", {"issue": "ACME-21", "project": "work"})

    path = notes.ensure(config, tasks, task)

    assert path == str(world / "vaults/acme/wiki/tasks/ACME-21 Old.md")
    assert open(path).read() == f"---\nissue: ACME-21\nstatus: active\ntask: {task['uuid']}\n---\n"


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
    text = open(path).read()
    assert "status: active" in text
    assert "closed:" not in text


def test_a_note_for_a_task_closed_already_starts_in_the_archive(config, tasks, world):
    """No hook will archive it later: that moment has passed."""
    task = tasks.add("done before its note", {"issue": "ACME-5", "project": "work"})
    tasks.done(task)
    tasks._task([task["uuid"], "modify", "end:2026-10-09T12:00:00"])
    tasks.invalidate()

    path = notes.ensure(config, tasks, tasks.get(task["uuid"]))

    assert path == str(world / "vaults/acme/wiki/tasks/archive/ACME-5 done before its note.md")
    assert f"created: {TODAY}\nstatus: done\nclosed: 2026-10-09\n---" in open(path).read()
    assert tasks.get(task["uuid"])["note"] == "wiki/tasks/archive/ACME-5 done before its note"


def test_the_archive_records_the_day_the_task_closed(config, tasks, world):
    task = tasks.add("closed last week", {"issue": "ACME-6", "project": "work"})
    notes.ensure(config, tasks, task)
    moved = notes.move_for_status(config, {**tasks.get(task["uuid"]), "end": "20261009T120000Z"}, closed=True)
    assert "closed: 2026-10-09\n" in (world / "vaults/acme" / (moved + ".md")).read_text()


def test_frontmatter_edits_leave_the_body_alone(tmp_path):
    note = tmp_path / "n.md"
    note.write_text("---\ntask: x\nstatus: active\n---\n\nstatus: in the body\n")
    notes.set_frontmatter(str(note), {"status": "done", "closed": "2026-01-01"})
    assert note.read_text() == "---\ntask: x\nstatus: done\nclosed: 2026-01-01\n---\n\nstatus: in the body\n"


def test_a_key_set_to_none_is_removed_from_the_frontmatter_only(tmp_path):
    note = tmp_path / "n.md"
    note.write_text("---\ntask: x\nclosed: 2026-01-01\nclosed_by: me\n---\n\nclosed: in the body\n")
    notes.set_frontmatter(str(note), {"closed": None})
    assert note.read_text() == "---\ntask: x\nclosed_by: me\n---\n\nclosed: in the body\n"


def test_no_note_nothing_to_move(config, tasks):
    assert notes.move_for_status(config, tasks.add("noteless"), closed=True) is None
