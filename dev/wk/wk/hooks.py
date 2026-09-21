"""Entry points for hooks: taskwarrior's, and later Claude's and tmux's.

Hooks must never get in the way. Every path here returns something valid, and
anything unexpected is swallowed rather than reported.
"""

import json
import re
import sys

CLOSED = ("completed", "deleted")


def task_on_modify(original, modified):
    """taskwarrior on-modify: file a task's note into the archive when the
    task is closed, and bring it back if the task is reopened. Takes the two
    JSON lines taskwarrior sends and returns the one to hand back.

    Only a status transition is interesting; everything else passes straight
    through, which keeps the common edit path free of any vault I/O. The
    cached note path is rewritten in the task handed back, rather than by
    shelling out to `task` from inside a hook.

    Known gap: `task undo` does not reach on-modify. Undo appends inverse
    operations at the storage layer instead of routing a task through the
    command layer, so it reverts the `note` UDA set here but not the file
    move. A note can therefore sit in the archive while its task is open.
    Nothing breaks: the uuid scan still finds it and the next real status
    change corrects the location.
    """
    if not modified.strip():
        return original
    try:
        before, after = json.loads(original), json.loads(modified)
        was_closed = before.get("status") in CLOSED
        is_closed = after.get("status") in CLOSED
        if was_closed == is_closed or not after.get("uuid"):
            return modified

        from . import notes
        from .config import Config

        moved = notes.move_for_status(Config.load(), after, closed=is_closed)
        if not moved or moved == after.get("note"):
            return modified
        after["note"] = moved
        return json.dumps(after, ensure_ascii=False, separators=(",", ":"))
    except Exception:
        return modified


PR_CREATE_RE = re.compile(r"(^|[;&|\s])gh\s+pr\s+create(\s|$)")
PR_URL_RE = re.compile(r"github\.com/([^/\s]+)/([^/\s]+)/pull/(\d+)")


def claude_post_tool_use(payload):
    """A session that opens a PR attaches it to its own task at once. Branch
    names often carry no issue key, and this session knows what the PR is
    for: that beats any guess sync could make later."""
    if payload.get("tool_name") != "Bash":
        return
    if not PR_CREATE_RE.search((payload.get("tool_input") or {}).get("command", "")):
        return
    url = PR_URL_RE.search(json.dumps(payload.get("tool_response", "")))
    if not url:
        return
    repo, number = f"{url.group(1)}/{url.group(2)}", url.group(3)

    from .resolve import resolve
    from .sync import format_prs, listed_prs
    from .tasks import Tasks, is_open

    tasks = Tasks()
    task = resolve(tasks, cwd=payload.get("cwd")).task
    if not task or not is_open(task) or (task.get("repo") and task["repo"].lower() != repo.lower()):
        return
    if tasks.by_pr(number, repo):
        return
    tasks.modify(task, {"prs": format_prs(listed_prs(task) + [number]), "repo": repo})


CLAUDE_EVENTS = {"post-tool-use": claude_post_tool_use}


def main(argv):
    """`wk hook claude <event>`, payload on stdin. Always exits 0."""
    try:
        if argv[:1] == ["claude"] and argv[1:2] and argv[1] in CLAUDE_EVENTS:
            CLAUDE_EVENTS[argv[1]](json.load(sys.stdin))
    except Exception:
        pass
    return 0
