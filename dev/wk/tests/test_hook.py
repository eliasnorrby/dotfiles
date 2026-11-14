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


def pr_created(cwd, url="https://github.com/acme/app/pull/77"):
    return {
        "tool_name": "Bash",
        "tool_input": {"command": "gh pr create --fill"},
        "tool_response": {"stdout": f"{url}\n"},
        "cwd": str(cwd),
    }


@needs_task
def test_a_pr_goes_to_the_task_of_its_branch(tasks, world):
    from wk import hooks

    # A parent's session, where a background agent opens a sub-issue's PR.
    parent = tasks.add("investigation", {"issue": "ACME-1", "worktree": str(world)})
    child = tasks.add("one part", {"issue": "ACME-2", "branch": "me/acme-2-one-part"})
    hooks.claude_post_tool_use(pr_created(world), head_of=lambda url: "me/acme-2-one-part")
    tasks.invalidate()
    assert tasks.get(child["uuid"])["prs"] == "#77"
    assert "prs" not in tasks.get(parent["uuid"])


def told(capsys):
    out = capsys.readouterr().out
    return json.loads(out)["hookSpecificOutput"]["additionalContext"] if out else ""


@needs_task
def test_a_side_pr_is_attached_to_nothing(tasks, world, capsys):
    from wk import hooks

    # A long review that splits a one-line fix out to a PR of its own: a
    # merged PR can finish the task it hangs on, so the review must not get it.
    checkout = world / "checkout"  # its own; home is shared and names no task
    checkout.mkdir()
    review = tasks.add("review the stack", {"worktree": str(checkout), "branch": "me/review-notes"})
    hooks.claude_post_tool_use(pr_created(checkout), head_of=lambda url: "me/a-side-quest")
    tasks.invalidate()
    assert "prs" not in tasks.get(review["uuid"])
    assert told(capsys).startswith("wk attached #77 to no task: its branch me/a-side-quest")


@needs_task
def test_a_pr_from_the_sessions_own_branch_goes_to_its_task(tasks, world, capsys):
    from wk import hooks

    checkout = world / "checkout"
    checkout.mkdir()
    task = tasks.add("tidy up", {"worktree": str(checkout), "branch": "me/tidy-up"})
    hooks.claude_post_tool_use(pr_created(checkout), head_of=lambda url: "me/tidy-up")
    tasks.invalidate()
    assert tasks.get(task["uuid"])["prs"] == "#77"
    assert told(capsys).startswith(f"wk attached #77 to task {task['uuid'][:8]} (tidy up)")


@needs_task
def test_the_branch_the_sessions_checkout_is_on_is_its_own(tasks, repo):
    from wk import hooks

    task = tasks.add("tidy up", {"worktree": str(repo)})  # repo is on someone/acme-12-fix-the-thing
    hooks.claude_post_tool_use(pr_created(repo), head_of=lambda url: "someone/acme-12-fix-the-thing")
    tasks.invalidate()
    assert tasks.get(task["uuid"])["prs"] == "#77"


@needs_task
def test_an_unknown_head_leaves_the_parent_alone(tasks, world, capsys):
    from wk import hooks

    # The orchestration case: an agent's PR for a sub-task, and GitHub could
    # not be asked for its head. The parent must not collect it.
    checkout = world / "checkout"
    checkout.mkdir()
    parent = tasks.add("database access", {"worktree": str(checkout), "branch": "me/database-access"})
    tasks.add("one part", {"issue": "ACME-2", "branch": "me/acme-2-one-part", "partof": parent["uuid"]})
    hooks.claude_post_tool_use(pr_created(checkout), head_of=lambda url: None)
    tasks.invalidate()
    assert "prs" not in tasks.get(parent["uuid"])
    assert "did not say which branch" in told(capsys)


@needs_task
def test_the_head_named_in_the_command_stands_in_for_githubs(tasks, world):
    from wk import hooks

    checkout = world / "checkout"
    checkout.mkdir()
    parent = tasks.add("database access", {"worktree": str(checkout), "branch": "me/database-access"})
    child = tasks.add("one part", {"issue": "ACME-2", "branch": "me/acme-2-one-part", "partof": parent["uuid"]})
    payload = pr_created(checkout)
    payload["tool_input"]["command"] = "gh pr create --draft --head me/acme-2-one-part --fill"
    hooks.claude_post_tool_use(payload, head_of=lambda url: None)
    tasks.invalidate()
    assert tasks.get(child["uuid"])["prs"] == "#77"
    assert "prs" not in tasks.get(parent["uuid"])


@needs_task
def test_a_sub_task_comes_before_another_task_on_the_branch(tasks, world):
    from wk import hooks

    checkout = world / "checkout"
    checkout.mkdir()
    stray = tasks.add("an older task on the branch", {"branch": "me/part"})
    parent = tasks.add("investigation", {"worktree": str(checkout), "branch": "me/investigation"})
    child = tasks.add("one part", {"branch": "me/part", "partof": parent["uuid"]})
    hooks.claude_post_tool_use(pr_created(checkout), head_of=lambda url: "me/part")
    tasks.invalidate()
    assert tasks.get(child["uuid"])["prs"] == "#77"
    assert "prs" not in tasks.get(stray["uuid"])


@needs_task
def test_a_sub_task_in_another_repo_gets_its_pr(tasks, world):
    from wk import hooks

    # The parent is in acme/app; its sub-issue's PR is in acme/infra and its
    # task has no repo yet. Found by the issue key in the head branch.
    checkout = world / "checkout"
    checkout.mkdir()
    parent = tasks.add("investigation", {"worktree": str(checkout), "repo": "acme/app", "branch": "me/inv"})
    child = tasks.add("infra part", {"issue": "ACME-3", "partof": parent["uuid"]})
    url = "https://github.com/acme/infra/pull/5"
    hooks.claude_post_tool_use(pr_created(checkout, url), head_of=lambda url: "me/acme-3-infra-part")
    tasks.invalidate()
    child = tasks.get(child["uuid"])
    assert (child["prs"], child["repo"]) == ("#5", "acme/infra")
    assert "prs" not in tasks.get(parent["uuid"])
