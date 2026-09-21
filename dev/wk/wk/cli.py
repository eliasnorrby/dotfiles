"""Command line.

Every command takes --json, and none reads the clipboard or opens a picker
unless told to: the callers are hooks, Claude and a timer as often as a
person. taskwarrior-tui appends the selected task's uuid to a shortcut's
command line, which here simply is the locator.
"""

import json
import os
import sys

from . import locator as locators
from .errors import NotFound, WkError

KIND_FLAGS = ("task", "issue", "pr", "branch", "dir", "window")


def kind_of(task):
    """What sort of work item this is. Derived, never stored, apart from the
    +review tag."""
    if "review" in task.get("tags", []):
        return "review"
    if task.get("issue"):
        return "work"
    if task.get("prs") or task.get("pr_number"):
        return "pr"
    return "work" if task.get("branch") else "todo"


def describe(task):
    fields = (
        "uuid",
        "id",
        "description",
        "status",
        "project",
        "issue",
        "note",
        "branch",
        "worktree",
        "state",
        "session",
    )
    out = {field: task[field] for field in fields if task.get(field) not in (None, "", 0)}
    if task.get("prs") or task.get("pr_number"):
        out["prs"] = task.get("prs") or task["pr_number"]
    out["kind"] = kind_of(task)
    out["tags"] = task.get("tags", [])
    return out


class Output:
    def __init__(self, args):
        self.as_json = getattr(args, "json", False)
        self.notify = getattr(args, "notify", False)
        self.display = getattr(args, "display", False)

    def _elsewhere(self, title, body, urgency="normal"):
        """Callers without a terminal (a tmux binding, a launcher menu) get
        the report where they can see it."""
        if self.display:
            from . import tmux

            tmux.display(body)
        if self.notify:
            from . import platform

            platform.notify(title, body, urgency)

    def result(self, payload, lines, title=None):
        if self.as_json:
            print(json.dumps({"ok": True, **payload}, ensure_ascii=False))
        else:
            for line in lines:
                print(line)
        self._elsewhere(title or "wk", "\n".join(lines))

    def error(self, err, extra=None):
        if self.as_json:
            body = {"ok": False, "error": {"code": err.name, "message": str(err)}, **(extra or {})}
            print(json.dumps(body, ensure_ascii=False))
        else:
            print(f"wk: {err}", file=sys.stderr)
        self._elsewhere("wk", str(err), "critical")


def context(args):
    from .config import Config
    from .tasks import Tasks

    return Config.load(), Tasks()


def locator_from(args, allow_selection=True):
    """The locator the command line names, or None for "here"."""
    text = args.locator
    # A uuid appended by the TUI is a selection, not a reference to import.
    if text and not allow_selection and locators.is_uuid(text):
        text = None
    if getattr(args, "source", None) == "clipboard":
        from . import platform

        text = platform.read_clipboard()
        if not text:
            raise NotFound("the clipboard is empty")
    elif getattr(args, "source", None) == "branch":
        text = None
    if not text:
        return None
    try:
        return locators.parse(text, force=args.kind)
    except ValueError as err:
        raise NotFound(str(err)) from err


def resolved(args, tasks, allow_selection=True):
    from .resolve import resolve

    cwd = os.path.realpath(args.directory or os.getcwd())
    return resolve(tasks, locator_from(args, allow_selection), cwd), cwd


def note_of(config, tasks, task, create):
    """The task's note and the vault it lives in. Without `create` this only
    looks: a plain resolve must not write anything."""
    from . import notes

    try:
        path = notes.ensure(config, tasks, task, create_missing=create, repair=create)
    except WkError:
        if create:
            raise
        path = None
    return path, (notes.vault_of(config, path) if path else None)


# -- commands --------------------------------------------------------------


def cmd_resolve(args, out):
    config, tasks = context(args)
    resolution, cwd = resolved(args, tasks)
    task = resolution.task

    if not task and (args.ensure or args.do_import):
        task = _import_missing(config, tasks, resolution, args.offline, cwd)
    if not task:
        what = resolution.issue or args.locator or cwd
        err = NotFound(f"no task for {what}")
        if args.format:
            sys.stdout.write(_line(_format(args.format, {"issue": resolution.issue, "branch": resolution.branch})))
        else:
            out.error(err, {"issue": resolution.issue, "branch": resolution.branch})
        return err.code

    note, vault = note_of(config, tasks, task, create=args.ensure)
    payload = {
        "task": describe(task),
        "issue": task.get("issue") or resolution.issue,
        "how": resolution.how,
        "note": note,
        "vault": vault,
    }
    if args.format:
        flat = {**payload["task"], **{k: v for k, v in payload.items() if k != "task"}}
        sys.stdout.write(_line(_format(args.format, flat)))
        return 0
    lines = [f"task={task['uuid']}"]
    lines += [f"{key}={payload[key]}" for key in ("issue", "vault", "note", "how") if payload[key]]
    out.result(payload, lines)
    return 0


def _import_missing(config, tasks, resolution, offline, cwd):
    if not resolution.reference:
        return None
    from .imports import import_reference

    return import_reference(config, tasks, resolution.reference, offline, resolution.branch, cwd).task


def _line(text):
    return f"{text}\n" if text else ""


def _format(template, values):
    """Fill a caller's template. All or nothing: when a field it names is
    unknown the result is empty, so `fixes: {issue}` never prints a bare
    "fixes: " into a PR description."""
    from string import Formatter

    known = {key: value for key, value in values.items() if value not in (None, "")}
    fields = [field.split(".")[0].split("[")[0] for _, field, _, _ in Formatter().parse(template) if field]
    return template.format_map(known) if all(field in known for field in fields) else ""


def cmd_import(args, out):
    from .imports import import_reference

    config, tasks = context(args)
    reference = locator_from(args, allow_selection=False)
    branch = None
    cwd = os.path.realpath(args.directory or os.getcwd())
    if reference is None or reference.kind in ("branch", "dir"):
        from .resolve import resolve

        resolution = resolve(tasks, reference, cwd)
        reference, branch = resolution.reference, resolution.branch
    if reference is None or reference.kind not in ("issue", "pr"):
        raise NotFound("no issue or PR reference found")

    imported = import_reference(config, tasks, reference, args.offline, branch, cwd)
    task = imported.task
    label = task.get("issue") or task.get("prs") or ""
    summary = f"{task.get('id') or task['uuid'][:8]}  {task['description']}  [{label}]"
    if not imported.created:
        title = "Already imported"
    elif imported.stub:
        title = "Task added (tracker unreachable; title to be filled in)"
    else:
        title = "Task added"
    out.result(
        {"task": describe(task), "created": imported.created, "stub": imported.stub},
        [f"{title}: {summary}"],
        title=title,
    )
    return 0


def cmd_note(args, out):
    config, tasks = context(args)
    resolution, _cwd = resolved(args, tasks)
    if not resolution.task:
        raise NotFound(f"no task for {resolution.issue or args.locator or 'this directory'}")
    path, vault = note_of(config, tasks, resolution.task, create=True)
    if args.print or args.json:
        out.result({"note": path, "vault": vault, "task": describe(resolution.task)}, [path])
        return 0
    editor = os.environ.get("EDITOR") or "nvim"
    os.execvp(editor, [editor, path])


def cmd_open_issue(args, out):
    from . import platform
    from .trackers import linear

    config, tasks = context(args)
    resolution, _cwd = resolved(args, tasks)
    key = resolution.issue
    if not key:
        raise NotFound("no issue found here")
    workspace = config.team(key).get("workspace")
    if not workspace:
        prefix = key.rsplit("-", 1)[0]
        raise WkError(f"set teams.{prefix}.workspace in {config.path} to open {key}")
    url = linear.app_url(workspace, key)
    platform.open_url(url)
    out.result({"issue": key, "url": url}, [url])
    return 0


def cmd_annotate(args, out):
    """Tie a tmux window to a piece of work: @task for wk, @issue and @desc
    for the pane border and the window switcher, and the window's name. Pure
    annotation, no branch or worktree side effects, so it is safe whether
    starting new work or resuming an existing checkout."""
    from . import tmux
    from .resolve import resolve

    config, tasks = context(args)
    target = args.target or os.environ.get("TMUX_PANE")
    if not target:
        raise WkError("not in tmux, and no -t WINDOW given")
    cwd = os.path.realpath(args.directory or tmux.pane_path(target) or os.getcwd())

    # An explicit locator stands alone. The clipboard, though, may hold
    # anything: when it names nothing, fall back to the window's own checkout.
    # "Here" is the target window's checkout, not the calling process's.
    here = locators.Locator("dir", cwd)
    try:
        attempts = [locator_from(args) or here]
    except NotFound:
        attempts = []
    if args.source == "clipboard":
        attempts.append(here)
    task = None
    for attempt in attempts:
        resolution = resolve(tasks, attempt, cwd)
        task = resolution.task or _import_missing(config, tasks, resolution, args.offline, cwd)
        if task:
            break
    if not task:
        raise NotFound("no issue, PR or task found to annotate the window with")

    label = task.get("issue") or str(task.get("prs") or task.get("pr_number") or "").split(",")[0]
    tmux.set_window_options(target, {"@task": task["uuid"], "@issue": label, "@desc": task["description"]})
    if label:
        tmux.rename_window(target, label)
    out.result({"task": describe(task), "window": target}, [" — ".join(filter(None, [label, task["description"]]))])
    return 0


def _workable_locator(config, args):
    """The locator to open. The clipboard may hold anything, so from there
    only what clearly names work counts: an issue, a PR, or a branch that
    looks like one of mine or carries an issue key. Failing that, ask, when
    there is someone to ask."""
    from .workspace import branch_prefix

    try:
        found = locator_from(args)
    except NotFound:
        found = None
    if args.source != "clipboard":
        return found
    if found and found.kind == "branch":
        mine = found.value.startswith(branch_prefix(config))
        if not (mine or locators.issue_key_in(found.value)):
            found = None
    if found and found.kind in ("issue", "pr", "branch"):
        return found
    if not (args.ask and sys.stdin.isatty()):
        raise NotFound("the clipboard holds no issue, PR or branch")
    while True:
        try:
            answer = input("Branch, issue or PR: ").strip()
        except (EOFError, KeyboardInterrupt):
            answer = ""
        if not answer:
            raise NotFound("nothing given")
        try:
            return locators.parse(answer)
        except ValueError:
            print("✗ not a branch, issue key or PR (empty aborts)", file=sys.stderr)


def cmd_open(args, out):
    from . import git, workspace
    from .resolve import resolve

    config, tasks = context(args)
    cwd = os.path.realpath(args.directory or os.getcwd())
    found = _workable_locator(config, args)
    resolution = resolve(tasks, found, cwd)
    task = resolution.task or _import_missing(config, tasks, resolution, args.offline, cwd)
    branch = args.on or (found.value if found and found.kind == "branch" else None)
    if not task and branch:
        # A branch that belongs to no issue (a colleague's, checked out for a
        # look) is still a piece of work, and gets a task like any other.
        repo = git.slug(cwd) if git.is_repo(cwd) else None
        words = branch.split("/", 1)[-1].replace("-", " ").replace("_", " ")
        attrs = {"branch": branch, "repo": repo, "project": config.project_for_repo(repo)}
        task = tasks.add(words, attrs)
    if not task:
        raise NotFound(f"no task for {resolution.issue or args.locator or cwd}")

    opened = workspace.ensure_window(config, tasks, task, cwd, branch=branch)
    if not args.no_switch:
        workspace.go(opened)
    payload = {
        "task": describe(tasks.get(task["uuid"])),
        "window": opened.window,
        "session": opened.session,
        "directory": opened.directory,
        "created_window": opened.created_window,
        "created_worktree": opened.created_worktree,
    }
    out.result(payload, [f"{opened.session}:{opened.window}  {opened.directory}"])
    return 0


def cmd_adopt(args, out):
    """Make a task out of work already under way: create it, and tie this
    directory, window and Claude session to it. For work that never had an
    issue, so it needs no ceremony to start and none to be remembered."""
    from . import git, state, tmux

    config, tasks = context(args)
    cwd = os.path.realpath(args.directory or os.getcwd())
    from .resolve import resolve

    existing = resolve(tasks, cwd=cwd).task
    if existing:
        raise WkError(f"this is already task {existing.get('id') or existing['uuid'][:8]}: {existing['description']}")
    repo = git.slug(cwd) if git.is_repo(cwd) else None
    attrs = {"repo": repo, "project": args.project or config.project_for_repo(repo)}
    top = git.toplevel(cwd)
    if top:
        attrs["worktree"] = top
        attrs["branch"] = git.branch(cwd)
    attrs["session"] = os.environ.get("CLAUDE_CODE_SESSION_ID")
    task = tasks.add(args.description, attrs)
    pane = os.environ.get("TMUX_PANE")
    if pane and not tmux.window_option(pane, "@task"):
        tmux.set_window_options(pane, {"@task": task["uuid"], "@desc": task["description"]})
    session_id = attrs["session"]
    if session_id:
        pid = int(os.environ.get("CLAUDE_PID") or 0) or os.getppid()
        state.write_agent(session_id, {"uuid": task["uuid"], "pane": pane, "pid": pid, "status": "working"})
    state.refresh(tasks, config, only=task["uuid"])
    out.result({"task": describe(tasks.get(task["uuid"]))}, [f"Task {task.get('id')}: {task['description']}"])
    return 0


def cmd_state(args, out):
    from . import state

    config, tasks = context(args)
    if args.refresh:
        state.reap()
        written = state.refresh(tasks, config)
        out.result({"written": written}, [f"{len(written)} task(s) updated"])
        return 0
    resolution, _cwd = resolved(args, tasks)
    if not resolution.task:
        raise NotFound(f"no task for {args.locator or 'this directory'}")
    value = resolution.task.get("state", "")
    out.result({"state": value, "session": resolution.task.get("session")}, [value or "-"])
    return 0


def cmd_start(args, out):
    """The one-gesture kickoff: task, note, worktree, window, Claude. Every
    step exists as a command of its own; this only strings them together. It
    never reads the clipboard and never opens a picker, so Claude can call it."""
    import shlex
    import uuid as uuids

    from . import git, workspace
    from .resolve import resolve

    config, tasks = context(args)
    cwd = os.path.realpath(args.directory or os.getcwd())
    plain_dir = None
    if args.new:
        repo = git.slug(cwd) if git.is_repo(cwd) else None
        task = tasks.add(args.new, {"repo": repo, "project": config.project_for_repo(repo)})
        plain_dir = git.main_worktree(cwd) if repo else cwd
    else:
        resolution = resolve(tasks, locator_from(args), cwd)
        task = resolution.task or _import_missing(config, tasks, resolution, args.offline, cwd)
        if not task:
            raise NotFound(f"no task for {resolution.issue or args.locator or cwd}")
    if args.partof:
        parent = resolve(tasks, locators.parse(args.partof), cwd).task
        if not parent:
            raise NotFound(f"no task for {args.partof}")
        tasks.modify(task, {"partof": parent["uuid"]})
        task = tasks.get(task["uuid"])

    note, _vault = note_of(config, tasks, task, create=True)
    task = tasks.get(task["uuid"])
    command = session = None
    if not args.no_claude:
        session = str(uuids.uuid4())
        prompt = args.prompt if args.prompt is not None else config.data.get("start", {}).get("prompt", "")
        command = shlex.join(["claude", "--session-id", session] + ([prompt] if prompt else []))
    opened = workspace.ensure_window(config, tasks, task, cwd, branch=args.on, command=command, plain_dir=plain_dir)
    launched = bool(command) and opened.created_window
    if launched:
        tasks.modify(tasks.get(task["uuid"]), {"session": session})
    if not args.no_switch:
        workspace.go(opened)
    payload = {
        "task": describe(tasks.get(task["uuid"])),
        "note": note,
        "window": opened.window,
        "session": opened.session,
        "directory": opened.directory,
        "claude": launched,
    }
    lines = [f"{opened.session}:{opened.window}  {opened.directory}"]
    if command and not launched:
        lines.append("the task already had a window; Claude was not started in it")
    out.result(payload, lines)
    return 0


def cmd_menu(args, out):
    """Every action valid for a task, in one fzf list, so that a new action
    never needs a key of its own."""
    import subprocess

    from . import prstatus

    _config, tasks = context(args)
    resolution, _cwd = resolved(args, tasks)
    task = resolution.task
    if not task:
        raise NotFound(f"no task for {args.locator or 'this directory'}")
    uuid = task["uuid"]
    prs = _task_prs(task) if (task.get("prs") or task.get("pr_number")) else []
    review = kind_of(task) == "review"

    actions = [("check out for review" if review else "open in tmux", ["open", "--pause-on-error", uuid])]
    actions.append(("note", ["note", uuid]))
    if task.get("issue"):
        actions.append((f"open issue {task['issue']}", ["open-issue", uuid]))
    for pr in prs:
        actions.append((f"open PR   {prstatus.summary(pr)}", ["open-pr", "--pick", pr["number"], uuid]))
    if not review:
        for pr in prs:
            actions.append(
                (f"merge PR  {prstatus.summary(pr)}", ("gh", "pr", "merge", pr["number"], "--repo", pr["repo"]))
            )
    if task.get("session"):
        actions.append(("resume Claude session", ("resume", task["session"])))
    if not review:
        actions.append(("start: note, window and Claude", ["start", "--pause-on-error", uuid]))
    actions.append(("sync now", ["sync", "--tracker", "--wait"]))

    if args.list or not sys.stdin.isatty():
        out.result({"actions": [label for label, _ in actions]}, [label for label, _ in actions])
        return 0
    labels = "\n".join(label for label, _ in actions)
    header = f"{task.get('issue') or ''} {task['description']}".strip()
    picked = subprocess.run(
        ["fzf", "--no-multi", "--no-sort", "--height=60%", "--header", header],
        input=labels,
        capture_output=True,
        text=True,
    )
    choice = next((action for label, action in actions if label == picked.stdout.rstrip("\n")), None)
    if choice is None:
        return 0
    if isinstance(choice, list):
        return main(choice)
    if choice[0] == "resume":
        return _resume(args, tasks, task, choice[1])
    code = subprocess.run(list(choice)).returncode
    input("Press Enter to continue...")
    return code


def _resume(args, tasks, task, session):
    """Bring the task's window up and resume its Claude session there, in a
    new pane: whatever runs in the window already is left alone."""
    import shlex

    from . import tmux, workspace

    config, _ = context(args)
    cwd = os.path.realpath(os.getcwd())
    command = shlex.join(["claude", "--resume", session])
    opened = workspace.ensure_window(config, tasks, task, cwd, command=command)
    if not opened.created_window:
        tmux.run("split-window", "-h", "-t", opened.window, "-c", opened.directory, command)
    workspace.go(opened)
    return 0


def cmd_show(args, out):
    _config, tasks = context(args)
    resolution, _cwd = resolved(args, tasks)
    if not resolution.task:
        raise NotFound(f"no task for {resolution.issue or args.locator or 'this directory'}")
    info = describe(resolution.task)
    out.result({"task": info, "how": resolution.how}, [f"{key}: {value}" for key, value in info.items()])
    return 0


def cmd_config(args, out):
    from .config import Config, config_path

    if args.action == "path":
        out.result({"path": config_path()}, [config_path()])
        return 0
    value = Config.load().get(args.key)
    text = value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)
    out.result({"key": args.key, "value": value}, [text])
    return 0


def cmd_doctor(args, out):
    import shutil
    import subprocess

    from .config import config_path
    from .trackers import linear

    def uda(name):
        result = subprocess.run(["task", "_get", f"rc.uda.{name}.type"], capture_output=True, text=True)
        return bool(result.stdout.strip())

    checks = [
        ("config file", os.path.isfile(config_path()), config_path()),
        ("task", bool(shutil.which("task")), "taskwarrior"),
        ("gh", bool(shutil.which("gh")), "GitHub CLI"),
        ("paste_cmd", bool(shutil.which("paste_cmd")), "clipboard reader (shell/clipboard)"),
        ("Linear API key", bool(linear.token()), "$LINEAR_API_KEY or ~/.config/linear/token"),
    ]
    if shutil.which("task"):
        for name in ("issue", "note", "note_flag", "branch", "worktree", "partof"):
            checks.append((f"uda.{name}", uda(name), "defined by dev/wk/taskrc"))
    lines = [f"{'ok     ' if ok else 'MISSING'} {name}  ({hint})" for name, ok, hint in checks]
    out.result({"checks": [{"name": n, "ok": ok} for n, ok, _ in checks]}, lines)
    return 0 if all(ok for _, ok, _ in checks) else 1


def cmd_sync(args, out):
    from . import sync as syncing
    from .trackers import github, linear

    held = syncing.lock()
    if held is None:
        out.result({"skipped": "another sync is running"}, ["another sync is running"])
        return 0
    config, tasks = context(args)
    report = syncing.Sync(config, tasks, github, linear, dry_run=args.dry_run).run(force_tracker=args.tracker)
    if not args.dry_run:
        from . import platform

        for title, body in report.notifications:
            platform.notify(title, body)
    lines = report.lines or ["nothing to do"]
    lines += [f"stale: {problem}" for problem in report.stale]
    out.result({"changes": report.lines, "stale": report.stale, "dry_run": args.dry_run}, lines)
    return 0


def cmd_status(args, out):
    """How fresh the synced data is."""
    import datetime

    from . import cache

    state = cache.read_state()

    def age(stamp):
        if not stamp:
            return "never"
        then = datetime.datetime.fromisoformat(stamp)
        minutes = int((datetime.datetime.now(datetime.UTC) - then).total_seconds() // 60)
        return "just now" if minutes < 1 else f"{minutes} min ago"

    lines = [f"github:  synced {age(state.get('last_ok'))}"]
    lines.append(f"tracker: synced {age(state.get('tracker', {}).get('last_ok'))}")
    lines += [f"{name} error: {message}" for name, message in state.get("errors", {}).items()]
    payload = {
        "last_ok": state.get("last_ok"),
        "tracker_last_ok": state.get("tracker", {}).get("last_ok"),
        "errors": state.get("errors", {}),
    }
    out.result(payload, lines)
    return 0


def _task_prs(task):
    from . import cache
    from .sync import listed_prs

    cached = {pr["number"]: pr for pr in cache.read_prs(task["uuid"])}
    numbers = listed_prs(task) or [str(task.get("pr_number", "")).split(".")[0].lstrip("#")]
    repo = task.get("repo") or task.get("pr_repo")
    return [cached.get(n, {"number": n, "repo": repo, "title": ""}) | {"repo": repo} for n in numbers if n]


def cmd_open_pr(args, out):
    from . import prstatus
    from .trackers.github import gh

    _config, tasks = context(args)
    resolution, _cwd = resolved(args, tasks)
    if not resolution.task:
        raise NotFound(f"no task for {args.locator or 'this directory'}")
    prs = _task_prs(resolution.task)
    if not prs:
        raise NotFound("this task has no PR")
    if args.pick:
        prs = [pr for pr in prs if pr["number"] == args.pick.lstrip("#")] or prs
    if len(prs) > 1:
        prs = [_pick(prs, prstatus.summary)]
    pr = prs[0]
    gh(["pr", "view", pr["number"], "--repo", pr["repo"], "--web"])
    out.result({"pr": pr["number"], "repo": pr["repo"]}, [f"#{pr['number']}"])
    return 0


def _pick(items, label):
    """Choose one with fzf. Only ever reached when a person is at a terminal;
    scripted callers name their choice instead."""
    import subprocess

    if not sys.stdin.isatty():
        choices = ", ".join(f"#{item['number']}" for item in items)
        raise WkError(f"several PRs ({choices}); name one with --pick")
    lines = "\n".join(label(item) for item in items)
    try:
        result = subprocess.run(["fzf", "--no-multi", "--height=40%"], input=lines, capture_output=True, text=True)
    except FileNotFoundError as err:
        raise WkError("fzf is not installed; name a PR with --pick") from err
    if result.returncode != 0 or not result.stdout.strip():
        raise NotFound("nothing picked")
    chosen = result.stdout.split()[0].lstrip("#")
    return next(item for item in items if item["number"] == chosen)


def cmd_attach_pr(args, out):
    """Move a PR onto a task by hand, when folding got it wrong."""
    from .sync import format_prs, listed_prs

    _config, tasks = context(args)
    pr = locators.parse(args.pr, force="pr")
    resolution, _cwd = resolved(args, tasks)
    target = resolution.task
    if not target:
        raise NotFound(f"no task for {args.locator or 'this directory'}")
    repo = pr.repo or target.get("repo")
    holder = tasks.by_pr(pr.value, repo)
    if holder and holder["uuid"] != target["uuid"] and holder.get("status") in ("pending", "waiting"):
        rest = [n for n in listed_prs(holder) if n != pr.value]
        if rest or kind_of(holder) != "pr":
            tasks.modify(holder, {"prs": format_prs(rest), "prstatus": None if not rest else holder.get("prstatus")})
        else:
            # A PR-only item exists for its PRs alone; with none left it is nothing.
            tasks.delete(holder)
        target = tasks.get(target["uuid"])
    numbers = listed_prs(target)
    if pr.value not in numbers:
        numbers.append(pr.value)
    tasks.modify(target, {"prs": format_prs(numbers), "repo": repo})
    out.result({"task": describe(tasks.get(target["uuid"]))}, [f"#{pr.value} -> {target['description']}"])
    return 0


# -- parser ----------------------------------------------------------------


def build_parser():
    import argparse

    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--json", action="store_true", help="machine-readable output")
    common.add_argument("--wait", "-w", action="store_true", help="pause before exiting (the TUI redraws over output)")
    common.add_argument("--pause-on-error", action="store_true", help="pause before exiting, but only after a failure")
    common.add_argument("--notify", "-n", action="store_true", help="also report via a desktop notification")
    common.add_argument("--display", action="store_true", help="also report in tmux's status line")

    def where_options(positional=True):
        options = argparse.ArgumentParser(add_help=False)
        if positional:
            options.add_argument(
                "locator", nargs="?", help="task, issue, PR, branch, directory or tmux window; default: here"
            )
        options.add_argument("-C", dest="directory", metavar="DIR", help="treat DIR as the working directory")
        options.add_argument(
            "--from",
            dest="source",
            choices=("clipboard", "branch"),
            help="take the locator from the clipboard, or from the branch only",
        )
        kinds = options.add_mutually_exclusive_group()
        for kind in KIND_FLAGS:
            kinds.add_argument(
                f"--{kind}", dest="kind", action="store_const", const=kind, help=f"read the locator as a {kind}"
            )
        return options

    where = where_options()

    parser = argparse.ArgumentParser(prog="wk", description=__doc__.split("\n\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("resolve", parents=[common, where], help="which task is this?")
    p.add_argument("--import", dest="do_import", action="store_true", help="import the task if there is none yet")
    p.add_argument("--ensure", action="store_true", help="--import, and create the note if missing")
    p.add_argument("--offline", action="store_true", help="never ask a tracker")
    p.add_argument("--format", metavar="TEMPLATE", help="print e.g. 'fixes: {issue}' instead")
    p.set_defaults(run=cmd_resolve)

    p = sub.add_parser("import", parents=[common, where], help="create a task from an issue or PR")
    p.add_argument("--offline", action="store_true", help="never ask a tracker; create a stub")
    p.set_defaults(run=cmd_import)

    p = sub.add_parser("note", parents=[common, where], help="open (or create) the task's note")
    p.add_argument("--print", action="store_true", help="print the path instead of opening an editor")
    p.set_defaults(run=cmd_note)

    p = sub.add_parser("open-issue", parents=[common, where], help="open the issue in its tracker")
    p.set_defaults(run=cmd_open_issue)

    p = sub.add_parser("annotate", parents=[common, where], help="tie a tmux window to a task")
    p.add_argument("-t", dest="target", metavar="WINDOW", help="the window to annotate; default: the current one")
    p.add_argument("--offline", action="store_true", help="never ask a tracker")
    p.set_defaults(run=cmd_annotate)

    p = sub.add_parser("open", parents=[common, where], help="open the task in tmux: window, worktree, branch")
    p.add_argument("--on", metavar="BRANCH", help="work on this branch rather than the task's or the tracker's")
    p.add_argument("--no-switch", action="store_true", help="create what is missing, but stay where I am")
    p.add_argument("--ask", action="store_true", help="with --from clipboard: prompt when it holds nothing usable")
    p.add_argument("--offline", action="store_true", help="never ask a tracker")
    p.set_defaults(run=cmd_open)

    p = sub.add_parser("adopt", parents=[common], help="make a task of the work already under way here")
    p.add_argument("description")
    p.add_argument("-C", dest="directory", metavar="DIR", help="treat DIR as the working directory")
    p.add_argument("--project", help="taskwarrior project; default: the repository's, from the config")
    p.set_defaults(run=cmd_adopt)

    p = sub.add_parser("state", parents=[common, where], help="a task's state; --refresh recomputes all of them")
    p.add_argument("--refresh", action="store_true")
    p.set_defaults(run=cmd_state)

    p = sub.add_parser("start", parents=[common, where], help="kick off work: task, note, window, Claude")
    p.add_argument("--new", metavar="DESCRIPTION", help="start untracked work: create the task first")
    p.add_argument("--prompt", help="Claude's first prompt; default: start.prompt from the config")
    p.add_argument("--no-claude", action="store_true", help="everything but Claude")
    p.add_argument("--partof", metavar="LOCATOR", help="record the task as part of another (a sub-issue's parent)")
    p.add_argument("--on", metavar="BRANCH", help="work on this branch")
    p.add_argument("--no-switch", action="store_true", help="stay where I am")
    p.add_argument("--offline", action="store_true", help="never ask a tracker")
    p.set_defaults(run=cmd_start)

    p = sub.add_parser("menu", parents=[common, where], help="pick among the actions valid for a task")
    p.add_argument("--list", action="store_true", help="print the actions instead of asking")
    p.set_defaults(run=cmd_menu)

    p = sub.add_parser("show", parents=[common, where], help="what wk knows about a task")
    p.set_defaults(run=cmd_show)

    p = sub.add_parser("sync", parents=[common], help="pull PR and issue status into taskwarrior")
    p.add_argument("--dry-run", action="store_true", help="show what would change")
    p.add_argument("--tracker", action="store_true", help="poll the issue tracker now, whatever its interval")
    p.add_argument("selection", nargs="?", help=argparse.SUPPRESS)  # the uuid the TUI appends; unused
    p.set_defaults(run=cmd_sync)

    p = sub.add_parser("status", parents=[common], help="how fresh the synced data is")
    p.set_defaults(run=cmd_status)

    p = sub.add_parser("open-pr", parents=[common, where], help="open the task's PR in the browser")
    p.add_argument("--pick", metavar="NUMBER", help="which PR, when the task has several")
    p.set_defaults(run=cmd_open_pr)

    p = sub.add_parser(
        "attach-pr", parents=[common, where_options(positional=False)], help="attach a PR to a task (default: here)"
    )
    p.add_argument("pr", help="the PR: #123 or its URL")
    p.add_argument("locator", nargs="?", help="the task to attach it to; default: here")
    p.set_defaults(run=cmd_attach_pr)

    p = sub.add_parser("config", parents=[common], help="read the configuration")
    p.add_argument("action", choices=("get", "path"))
    p.add_argument("key", nargs="?", default="")
    p.set_defaults(run=cmd_config)

    p = sub.add_parser("doctor", parents=[common], help="check that everything wk needs is in place")
    p.set_defaults(run=cmd_doctor)
    return parser


def main(argv):
    if argv[:1] == ["hook"]:
        # Before argparse is even imported: hooks run on every prompt.
        from .hooks import main as hook_main

        return hook_main(argv[1:])
    args = build_parser().parse_args(argv)
    out = Output(args)
    code = 1
    try:
        code = args.run(args, out) or 0
    except WkError as err:
        out.error(err)
        code = err.code
    except KeyboardInterrupt:
        code = 130
    finally:
        # Callers like the TUI or a tmux popup redraw or close as soon as this
        # exits, taking the output with them.
        pause = getattr(args, "wait", False) or (code != 0 and getattr(args, "pause_on_error", False))
        if pause and sys.stdin.isatty():
            try:
                input("Press Enter to continue...")
            except (EOFError, KeyboardInterrupt):
                pass
    return code
