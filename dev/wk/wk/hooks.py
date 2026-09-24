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

    Which task: the one the PR's head branch belongs to, else the session's.
    A PR belongs to a branch, and a session may open PRs for several: a
    parent's background agents each open one for their own sub-issue, from
    inside the parent's window."""
    if payload.get("tool_name") != "Bash":
        return
    if not PR_CREATE_RE.search((payload.get("tool_input") or {}).get("command", "")):
        return
    url = PR_URL_RE.search(json.dumps(payload.get("tool_response", "")))
    if not url:
        return
    repo, number = f"{url.group(1)}/{url.group(2)}", url.group(3)

    from .locator import Locator
    from .resolve import resolve
    from .sync import format_prs, listed_prs
    from .tasks import Tasks, is_open

    tasks = Tasks()
    head = (head_of or _pr_head)(url.group(0))
    task = resolve(tasks, Locator("branch", head)).task if head else None
    if not task or not is_open(task):
        task = resolve(tasks, cwd=payload.get("cwd")).task
    if not task or not is_open(task) or (task.get("repo") and task["repo"].lower() != repo.lower()):
        return
    if tasks.by_pr(number, repo):
        return
    tasks.modify(task, {"prs": format_prs(listed_prs(task) + [number]), "repo": repo})


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
to another task, adopt that one with --task. Only a one-off question answered in a turn or two needs no \
task."""

CLEARED = """\
This window is tied to task {id} ({description}). If what you are asked now is other work, move this \
session to it before starting: `wk adopt --task <id>` for a pending task, `wk adopt "<short description>"` \
for new work."""


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
        uuid = _session_task(event, payload)
        if not uuid:
            return
        agent = {"uuid": uuid, "pane": os.environ.get("TMUX_PANE"), "status": None}
        agent["pid"] = int(os.environ.get("CLAUDE_PID") or 0) or os.getppid()
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
    task = resolve(Tasks(), cwd=cwd).task
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
