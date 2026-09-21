"""Entry points for hooks: taskwarrior's, and later Claude's and tmux's.

Hooks must never get in the way. Every path here returns something valid, and
anything unexpected is swallowed rather than reported.
"""

import json

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
