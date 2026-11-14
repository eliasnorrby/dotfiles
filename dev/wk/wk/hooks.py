"""Entry points for hooks: taskwarrior's, and later Claude's and tmux's.

Hooks must never get in the way. Every path here returns something valid, and
anything unexpected is swallowed rather than reported.
"""

import json
import os
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


def claude_post_tool_use(payload, head_of=None):
    """A session that opens a PR attaches it to its task at once. Branch
    names often carry no issue key, and this session knows what the PR is
    for: that beats any guess sync could make later.

    A PR belongs to a branch, and a session may open PRs for several: a
    parent's background agents each open one for their own sub-issue, from
    inside the parent's window, and a session may split a side fix out of
    its work. So the head branch decides (see _pr_owner), and a PR whose
    head is no branch of the session's is attached to nothing: a merged PR
    can finish the task it is attached to. Sync folds it later by its
    branch, and the session is told either way."""
    if payload.get("tool_name") != "Bash":
        return
    command = (payload.get("tool_input") or {}).get("command", "")
    if not PR_CREATE_RE.search(command):
        return
    if not _registers_work():
        return
    url = PR_URL_RE.search(json.dumps(payload.get("tool_response", "")))
    if not url:
        return
    repo, number = f"{url.group(1)}/{url.group(2)}", url.group(3)

    from .resolve import resolve
    from .sync import format_prs, listed_prs
    from .tasks import Tasks, is_open

    tasks = Tasks()
    if tasks.by_pr(number, repo):
        return
    head = (head_of or _pr_head)(url.group(0)) or _head_in_command(command)
    session = resolve(tasks, cwd=payload.get("cwd"), session=payload.get("session_id")).task
    task, why = _pr_owner(tasks, repo, head, session if session and is_open(session) else None)
    if not task:
        _emit_context(
            "PostToolUse",
            f"wk attached #{number} to no task: {why}. Sync will file it by its branch; if it belongs to a task"
            f" of yours, `wk attach-pr https://{url.group(0)} <task>`.",
        )
        return
    tasks.modify(task, {"prs": format_prs(listed_prs(task) + [number]), "repo": repo})
    label = " ".join(filter(None, [task.get("issue"), task["description"]]))
    _emit_context("PostToolUse", f"wk attached #{number} to task {task['uuid'][:8]} ({label}): {why}.")


def _pr_owner(tasks, repo, head, session):
    """The task a new PR from branch `head` belongs to, and why; (None, why
    not) when none. First hit wins:

    1. a sub-task of the session's task: by its branch, then by the issue
       key in the head branch,
    2. the task of the head branch itself (its branch, else its issue),
    3. the session's task, when the head is its own branch: the one it
       records, or the one its checkout is on.

    Each is checked against the PR's repository by its own `repo`, so a
    parent in one repository still finds its sub-task's PR in another."""
    from .locator import Locator, issue_key_in
    from .resolve import resolve
    from .tasks import is_open

    def fits(task):
        return bool(task) and is_open(task) and (not task.get("repo") or task["repo"].lower() == repo.lower())

    if not head:
        return None, "GitHub did not say which branch it is from"
    if session:
        children = [task for task in tasks.all() if task.get("partof") == session["uuid"] and fits(task)]
        for task in children:
            if task.get("branch") == head:
                return task, "a sub-task of this session's, by its branch"
        key = issue_key_in(head)
        for task in children if key else ():
            if task.get("issue") == key:
                return task, f"a sub-task of this session's, by {key} in the branch"
    task = resolve(tasks, Locator("branch", head)).task
    if fits(task):
        return task, f"the task of branch {head}"
    if session and fits(session) and head in _own_branches(session):
        return session, f"this session's, whose checkout is on {head}"
    return None, f"its branch {head} belongs neither to this session's task nor to a sub-task of it"


def _own_branches(task):
    from . import git

    branches = {task.get("branch")}
    if task.get("worktree") and os.path.isdir(task["worktree"]):
        branches.add(git.branch(task["worktree"]))
    return branches - {None, ""}


HEAD_FLAG_RE = re.compile(r"(?:^|\s)(?:--head|-H)[=\s]+['\"]?([^\s'\"]+)")


def _head_in_command(command):
    """The branch `gh pr create --head X` names, `owner:` dropped; None when
    the command leaves it to the checkout, which this hook cannot see."""
    match = HEAD_FLAG_RE.search(command)
    return match.group(1).split(":", 1)[-1] if match else None


def _pr_head(url):
    """The PR's head branch; None when GitHub cannot say. One round trip,
    paid once per PR created."""
    from .errors import WkError
    from .trackers.github import gh

    try:
        return gh(["pr", "view", url, "--json", "headRefName", "--jq", ".headRefName"]).strip() or None
    except WkError:
        return None


def _emit_context(event, text):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": text}}))


NO_TASK = """\
No wk task is tied to this session yet (no @task on the tmux window, no task for this directory, worktree \
or branch). Every piece of work gets one: taskwarrior is the register of every session, running or past. \
As soon as you know what the first request is about, and before you start on it, register it yourself, \
without asking:

- If a pending task already describes it (`task project:<name> list`), take it: `wk adopt --task <id>`.
- Otherwise create one: `wk adopt "<short description>"`. Here it lands in project `{project}`; add \
`--project <name>` when the work belongs elsewhere (projects: {projects}).

Either starts the task, ties this window and session to it and names the session. When the work moves on \
to another task, adopt that one with --task. Two things need no task: a one-off question answered in a \
turn or two, and recording a source in the wiki (the `record` skill), which is an operation on the wiki, \
logged there."""

CLEARED = """\
This window was tied to task {id} ({description}), but this new session is not recorded on it yet. As soon \
as you know what you are asked to do, and before you start, register it: `wk adopt --task {id}` if it is \
the same work, `wk adopt --task <id>` for another pending task, `wk adopt "<short description>"` for new \
work."""


NOT_REGISTERED = """\
This machine does not register work (tasks.register = false in wk's config): its taskwarrior is not the \
register the notes and trackers know, so no task is tied to this session and none should be. Don't adopt \
or create one (wk refuses to here); go straight to the request."""


def _registers_work():
    from .config import Config

    return Config.load().registers_work


def _interactive():
    """Headless runs (`claude -p`, the SDK) are scheduled jobs, not work
    sessions: they get no task."""
    return not os.environ.get("CLAUDE_CODE_ENTRYPOINT", "").startswith("sdk")


def _no_task_context(cwd):
    from . import git
    from .config import Config

    config = Config.load()
    repo = git.slug(cwd) if git.is_repo(cwd) else None
    project = config.project_for_directory(cwd, repo)
    return NO_TASK.format(project=project, projects=", ".join(config.project_names()))


def _agent_status(event, payload, current):
    """The agent status an event leads to, or None to leave it alone."""
    if event in ("session-start", "stop", "stop-failure"):
        return "idle"
    if event == "user-prompt-submit":
        return "working"
    if event == "permission-request":
        return "input"
    if event == "post-tool-use":
        # A granted permission sends no prompt; the next tool call is the
        # sign that the agent is moving again.
        return "working" if current == "input" else None
    if event == "notification":
        kind = payload.get("notification_type") or ""
        message = (payload.get("message") or "").lower()
        if kind in ("permission_prompt", "elicitation_dialog") or "permission" in message:
            return "input"
        if kind == "idle_prompt" or "waiting for your input" in message:
            # Never downgrade a pending question to mere idleness.
            return None if current == "input" else "idle"
    return None


def claude_event(event, payload):
    """Claude's lifecycle, pushed onto the session's task as its state."""
    from . import state

    session_id = payload.get("session_id")
    if not session_id:
        return
    if event == "user-prompt-submit":
        # What happened to the session's task while it was not looking (sync
        # completed it, say), told before it acts on this prompt.
        notices = state.take_notices(session_id)
        if notices:
            _emit_context("UserPromptSubmit", "\n\n".join(notices))
    if event == "session-end":
        agent = state.read_agent(session_id)
        state.remove_agent(session_id)
        if agent:
            _refresh(agent.get("uuid"))
        return

    agent = state.read_agent(session_id)
    if agent is None:
        if event == "post-tool-use":
            return  # the hot path: a session without a task costs nothing more
        if not _registers_work():
            if event == "session-start" and payload.get("source") in (None, "startup", "clear") and _interactive():
                _emit_context("SessionStart", NOT_REGISTERED)
            return
        uuid = _session_task(event, payload)
        if not uuid:
            return
        agent = {"uuid": uuid, "pane": os.environ.get("TMUX_PANE"), "status": None}
        agent["pid"] = int(os.environ.get("CLAUDE_PID") or 0) or os.getppid()
        if event == "session-start" and payload.get("source") == "clear":
            # /clear starts a new session in a window that still names the
            # work before it, and the new session may be about something
            # else. It stays unattached, so the task keeps leading back to
            # the conversation that did its work, until the session adopts
            # a task (`wk adopt`, which the CLEARED context asks for).
            agent["uuid"] = None
    status = _agent_status(event, payload, agent.get("status"))
    if status is None or status == agent.get("status"):
        return
    agent["status"] = status
    state.write_agent(session_id, agent)
    _refresh(agent["uuid"], session_id if event == "session-start" else None)


def _session_task(event, payload):
    """Which task a session belongs to. The window's @task is cheap and
    authoritative; the slower layers only run once, when the session starts."""
    from . import tmux
    from .tasks import Tasks, is_open

    uuid = tmux.current_task()
    if event != "session-start":
        return uuid
    source = payload.get("source")
    if uuid:
        # After /clear the window still names the work before it.
        task = Tasks().get(uuid) if source == "clear" and _interactive() else None
        if task and is_open(task):
            told = CLEARED.format(id=task.get("id") or uuid[:8], description=task["description"])
            _emit_context("SessionStart", told)
        return uuid
    from .resolve import resolve

    cwd = payload.get("cwd") or "."
    task = resolve(Tasks(), cwd=cwd, session=payload.get("session_id")).task
    if task and is_open(task):
        return task["uuid"]
    if source in (None, "startup", "clear") and _interactive():
        _emit_context("SessionStart", _no_task_context(cwd))
    return None


def _refresh(uuid, session_id=None):
    from . import state
    from .tasks import Tasks

    if not uuid:
        return
    tasks = Tasks()
    task = tasks.get(uuid)
    if not task:
        return
    if session_id:
        # So the work can be resumed with `claude --resume <id>`, which finds
        # sessions from any directory.
        tasks.modify(task, {"session": session_id})
    state.refresh(tasks, only=uuid)


CLAUDE_STATE_EVENTS = (
    "session-start",
    "session-end",
    "user-prompt-submit",
    "notification",
    "permission-request",
    "stop",
    "stop-failure",
    "post-tool-use",
)


def main(argv):
    """`wk hook claude <event>` (payload on stdin) and `wk hook tmux <event>`.
    Always exits 0."""
    try:
        if argv[:1] == ["claude"] and argv[1:2]:
            payload = json.load(sys.stdin)
            if argv[1] == "post-tool-use":
                claude_post_tool_use(payload)
            if argv[1] in CLAUDE_STATE_EVENTS:
                claude_event(argv[1], payload)
        elif argv[:1] == ["tmux"]:
            # A window came or went; which one is unknowable afterwards (a
            # dead window's options are gone), so look at everything.
            from . import state
            from .tasks import Tasks

            state.refresh(Tasks())
    except Exception:
        pass
    return 0
