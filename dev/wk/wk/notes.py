"""Task notes in the Obsidian vaults.

The note's path is cached in the task's `note` UDA for fast lookup, but the
durable link is the `task:` field in the note's frontmatter. A note renamed or
moved inside Obsidian is recovered by uuid and the stale UDA repaired, so
renaming in Obsidian never breaks the connection.

The vault follows from the task's project; no vault name is baked in.
"""

import datetime
import os
import re
import shutil
import subprocess

from .errors import WkError

FRONTMATTER_BYTES = 4096
CLOSED = ("completed", "deleted")

TEMPLATE = """---
{frontmatter}
---

# {title}

## Plan

- [ ]{space}

## Findings

"""


def subdir_for_vault(config, vault_path):
    """Vaults need not share a layout: the first candidate that exists wins,
    and a vault with none gets the first."""
    for candidate in config.note_subdirs:
        if os.path.isdir(os.path.join(vault_path, candidate)):
            return candidate
    return config.note_subdirs[0]


def slugify(text):
    """Make a description safe for a filename without mangling it beyond
    recognition: these names are meant to be read in Obsidian's file list.
    A wikilink reads # as a heading and ^ as a block, so a name with either
    can't be linked; they go, as do the brackets and the pipe."""
    slug = re.sub(r"[/:\\|]", "-", text)
    slug = re.sub(r"[#^\[\]]", "", slug)
    slug = re.sub(r"\s+", " ", slug).strip()
    return slug[:60].rstrip()


FRONTMATTER_LINE = re.compile(r"([A-Za-z_][\w-]*):[ \t]*(.*)")


def frontmatter_of(path):
    """A note's top-level `key: value` frontmatter lines, as a dict; empty
    for a note without (complete) frontmatter."""
    try:
        with open(path, "rb") as handle:
            head = handle.read(FRONTMATTER_BYTES).decode("utf-8", "replace")
    except OSError:
        return {}
    lines = head.splitlines()
    if not lines or lines[0] != "---":
        return {}
    found = {}
    for line in lines[1:]:
        if line == "---":
            return found
        match = FRONTMATTER_LINE.fullmatch(line)
        if match:
            found.setdefault(match.group(1), match.group(2).strip().strip("\"'"))
    return {}


def _links_task(path, uuid):
    return frontmatter_of(path).get("task") == uuid


def _scan(directory, uuid):
    for root, _dirs, files in os.walk(directory):
        for name in sorted(files):
            if name.endswith(".md") and _links_task(os.path.join(root, name), uuid):
                return os.path.join(root, name)
    return None


def find_in_vault(config, vault_path, task):
    """Prefer the cached path, then fall back to a uuid scan so a note renamed
    inside Obsidian is still found."""
    cached = task.get("note")
    if cached:
        path = os.path.join(vault_path, cached + ".md")
        if os.path.isfile(path):
            return path
    return _scan(os.path.join(vault_path, subdir_for_vault(config, vault_path)), task["uuid"])


def find_anywhere(config, task):
    """Search every vault. Used where a note only has to be *found*, never
    placed, so no project-to-vault mapping is needed."""
    try:
        vaults = sorted(os.scandir(config.vaults_dir), key=lambda entry: entry.name)
    except OSError:
        return None
    vaults = [entry.path for entry in vaults if entry.is_dir() and not entry.name.startswith(".")]
    cached = task.get("note")
    if cached:
        for vault in vaults:
            path = os.path.join(vault, cached + ".md")
            if os.path.isfile(path):
                return path
    for vault in vaults:
        for subdir in config.note_subdirs:
            found = _scan(os.path.join(vault, subdir), task["uuid"])
            if found:
                return found
    return None


def issue_of(task):
    """The task's issue key, picked out of the description when the UDA is
    empty."""
    if task.get("issue"):
        return task["issue"]
    match = re.search(r"(?<![A-Z-])([A-Z]+-\d+)\b", task.get("description", ""))
    return match.group(1) if match else None


def title_for(task):
    """The note's name, which is also its heading. An issue key is the
    strongest identifier available, so it leads; otherwise fall back to the
    date convention used elsewhere."""
    description = task.get("description", "")
    issue = issue_of(task)
    if issue:
        rest = slugify(re.sub(rf"^{re.escape(issue)}[\s:._-]*", "", description))
        return f"{issue} {rest}".strip()
    return f"{datetime.date.today().isoformat()} {slugify(description)}".strip()


def _free_path(directory, title):
    path = os.path.join(directory, f"{title}.md")
    suffix = 2
    while os.path.exists(path):
        path = os.path.join(directory, f"{title} ({suffix}).md")
        suffix += 1
    return path


def is_closed(task):
    return task.get("status") in CLOSED


def closed_on(task):
    """The day the task closed, in local time: its `end`, else today."""
    try:
        moment = datetime.datetime.strptime(task.get("end", ""), "%Y%m%dT%H%M%SZ")
    except ValueError:
        return datetime.date.today().isoformat()
    return moment.replace(tzinfo=datetime.UTC).astimezone().date().isoformat()


def home_of(config, vault_path, closed):
    """Where a task's note belongs: the task folder, or its archive while the
    task is closed."""
    directory = os.path.join(vault_path, subdir_for_vault(config, vault_path))
    return os.path.join(directory, config.archive_subdir) if closed else directory


def is_archived(config, path):
    """Whether a note's path (vault-relative or not) is in an archive."""
    return os.path.basename(os.path.dirname(path)) == config.archive_subdir


def create(config, vault_path, task):
    """A new note for the task, where its status says it belongs: a task
    that closed before it had a note (the hook that archives had nothing to
    move then) gets its note in the archive, done, at once."""
    closed = is_closed(task)
    directory = home_of(config, vault_path, closed)
    issue = issue_of(task)
    today = datetime.date.today().isoformat()
    title = title_for(task)

    # A note may already stand for this work: one backfilled before the task
    # existed, say. A second one, with a "(2)" in its name, would split the
    # work's history in two, so it is adopted instead, or this refuses.
    claimants = _claimants(config, vault_path, issue, f"{title}.md")
    for path, owner in claimants:
        if not owner:
            return _adopt(config, path, task)
    if claimants:
        path, owner = claimants[0]
        raise WkError(
            f"{os.path.relpath(path, vault_path)} already stands for {issue or title}, for another task "
            f"({owner}); a second note would split its history. If this task carries that work on, put "
            f"`task: {task['uuid']}` in that note's frontmatter (or reopen that task instead) and run this again."
        )

    os.makedirs(directory, exist_ok=True)
    path = os.path.join(directory, f"{title}.md")

    frontmatter = [f"task: {task['uuid']}"]
    if issue:
        frontmatter.append(f"issue: {issue}")
    if task.get("project"):
        frontmatter.append(f"project: {task['project']}")
    frontmatter.append(f"created: {today}")
    frontmatter += ["status: done", f"closed: {closed_on(task)}"] if closed else ["status: active"]

    with open(path, "x", encoding="utf-8") as handle:
        # The heading is the file name, so heading and link target agree.
        handle.write(TEMPLATE.format(frontmatter="\n".join(frontmatter), title=title, space=" "))
    return path


def _claimants(config, vault_path, issue, filename):
    """Notes that already stand for the work a new note named FILENAME would
    be about: those with its issue in their frontmatter, and any of that
    name. As (path, the task uuid it names or None), best first: the very
    name, then one outside the archive."""
    found = []
    for root, _dirs, files in os.walk(os.path.join(vault_path, subdir_for_vault(config, vault_path))):
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(root, name)
            meta = frontmatter_of(path)
            if name == filename or (issue and meta.get("issue", "").upper() == issue.upper()):
                found.append((path, meta.get("task") or None))
    return sorted(found, key=lambda f: (os.path.basename(f[0]) != filename, is_archived(config, f[0]), f[0]))


def _adopt(config, path, task):
    """Tie a note that names no task to this one, and file it where the
    task's status says it belongs, as the hook would have."""
    set_frontmatter(path, {"task": task["uuid"]})
    closed = is_closed(task)
    if is_archived(config, path) != closed:
        moved = move_for_status(config, task, closed, path=path)
        if moved:
            path = os.path.join(vault_of(config, path), moved + ".md")
    return path


def vault_path_for(config, task):
    vault = config.vault_for_project(task.get("project"))
    path = os.path.join(config.vaults_dir, vault)
    if not os.path.isdir(path):
        raise WkError(f"vault not found: {path}")
    return path


def vault_of(config, note_path):
    """The vault root a note lives in."""
    rest = os.path.relpath(note_path, config.vaults_dir)
    return os.path.join(config.vaults_dir, rest.split(os.sep)[0])


def ensure(config, tasks, task, create_missing=True, repair=True):
    """Find the task's note, creating it if allowed, and repair the cached
    path and the list marker on the task. Returns the path or None."""
    vault_path = vault_path_for(config, task)
    path = find_in_vault(config, vault_path, task)
    if not path:
        if not create_missing:
            return None
        path = create(config, vault_path, task)
    cached = os.path.splitext(os.path.relpath(path, vault_path))[0]
    # note_flag mirrors "this task has a note" into a one-character UDA purely
    # so the task list can show it: taskwarrior-tui ignores the .indicator
    # column format, so a marker has to be a real value in a column of its own.
    if repair:
        tasks.modify(task, {"note": cached, "note_flag": config.note_flag})
    return path


def follow_issue(config, tasks, task):
    """The task has just been given an issue: its note follows. Renamed to
    what create() would call it now (`<KEY> <title>.md`), into the vault the
    task's project maps to, with `issue:` (and `project:`) in its
    frontmatter, the heading renamed with it, and links to it elsewhere in
    the vault repointed, since a rename outside Obsidian updates none. Its
    content and `task:` stay. Returns the new path, or None when the task
    has no note yet."""
    path = find_anywhere(config, task)
    if not path:
        return None
    old_vault, old_title = vault_of(config, path), os.path.splitext(os.path.basename(path))[0]
    vault_path = vault_path_for(config, task)
    directory = os.path.join(vault_path, subdir_for_vault(config, vault_path))
    title = title_for(task)
    destination = path
    if title != old_title or os.path.dirname(path) != directory:
        os.makedirs(directory, exist_ok=True)
        destination = _free_path(directory, title)
        os.rename(path, destination)
    new_title = os.path.splitext(os.path.basename(destination))[0]
    values = {"issue": issue_of(task)}
    if task.get("project"):
        values["project"] = task["project"]
    set_frontmatter(destination, values)
    if new_title != old_title:
        _retitle(destination, old_title, new_title)
        if old_vault == vault_path:
            relink(vault_path, old_title, new_title)
    tasks.modify(task, {"note": os.path.splitext(os.path.relpath(destination, vault_path))[0]})
    return destination


def _retitle(path, old, new):
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    replaced = re.sub(rf"^# {re.escape(old)}$", lambda _: f"# {new}", text, count=1, flags=re.M)
    if replaced != text:
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(replaced)


def relink(vault_path, old, new):
    """Point wikilinks to the note OLD at NEW, in every note of the vault:
    [[OLD]], [[OLD|alias]], [[OLD#heading]] and [[dir/OLD]] alike."""
    pattern = re.compile(r"\[\[((?:[^\]|#\n]*/)?)" + re.escape(old) + r"(?=[\]|#])")
    for root, dirs, files in os.walk(vault_path):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(root, name)
            try:
                with open(path, encoding="utf-8") as handle:
                    text = handle.read()
            except (OSError, UnicodeDecodeError):
                continue
            replaced = pattern.sub(lambda match: f"[[{match.group(1)}{new}", text)
            if replaced != text:
                with open(path, "w", encoding="utf-8") as handle:
                    handle.write(replaced)


# -- archiving -----------------------------------------------------------


def set_frontmatter(path, values):
    """Set frontmatter keys, inserting them before the closing delimiter when
    the note does not carry them yet; a value of None removes the key.
    Confined to the frontmatter block so a matching line in the note body is
    left alone."""
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().split("\n")
    if not lines or lines[0] != "---":
        return
    try:
        end = lines.index("---", 1)
    except ValueError:
        return
    block = lines[1:end]
    for key, value in values.items():
        if value is None:
            block = [line for line in block if not _is_key(line, key)]
            continue
        line = f"{key}: {value}"
        for index, existing in enumerate(block):
            if _is_key(existing, key):
                block[index] = line
                break
        else:
            block.append(line)
    temporary = f"{path}.tmp.{os.getpid()}"
    with open(temporary, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines[:1] + block + lines[end:]))
    os.replace(temporary, path)


def _is_key(line, key):
    return line == f"{key}:" or line.startswith(f"{key}: ")


def move_for_status(config, task, closed, path=None):
    """File a closed task's note into the archive, or bring it back. Returns
    the note's new vault-relative path (no extension), or None when there is
    no note. The note is looked for unless its PATH is given."""
    path = path or find_anywhere(config, task)
    if not path:
        return None
    vault_path = vault_of(config, path)
    directory = home_of(config, vault_path, closed)
    os.makedirs(directory, exist_ok=True)
    destination = os.path.join(directory, os.path.basename(path))
    if path != destination:
        if os.path.exists(destination):
            return None
        os.rename(path, destination)
    if closed:
        set_frontmatter(destination, {"status": "done", "closed": closed_on(task)})
    else:
        # A reopened task is not closed, whenever it was.
        set_frontmatter(destination, {"status": "active", "closed": None})
    if path != destination:
        commit_move(vault_path, path, destination)
    return os.path.splitext(os.path.relpath(destination, vault_path))[0]


# How long a move waits for a checkpoint holding the vault's commit lock. It
# runs inside taskwarrior's hook, so `task done` waits too; a commit holds the
# lock for a fraction of a second, and the sweep takes what this gives up on.
COMMIT_LOCK_WAIT = 5
GIT_LOCATION = ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR", "GIT_OBJECT_DIRECTORY")


def commit_move(vault_path, old, new):
    """Commit a move made here, as a rename, at once: left in the working
    tree, a session checkpointing meanwhile would commit the old path's
    deletion. Goes through `wiki_checkpoint moved` (dotfiles topic ai/os),
    which takes the vault's commit lock and pushes to its backup like every
    checkpoint. Where that is missing, or the vault has no repository (a
    synced copy), nothing is committed; the sweep takes it later. Never
    raises: this runs inside taskwarrior's hook. Returns whether it
    committed."""
    script = shutil.which("wiki_checkpoint")
    if not script or not os.path.isdir(os.path.join(vault_path, ".git")):
        return False
    # `task done` run from inside a git hook would hand git another repository.
    env = {key: value for key, value in os.environ.items() if key not in GIT_LOCATION}
    env["WIKI_CHECKPOINT_LOCK_WAIT"] = str(COMMIT_LOCK_WAIT)
    try:
        result = subprocess.run(
            [script, "moved", vault_path, old, new],
            capture_output=True,
            stdin=subprocess.DEVNULL,
            env=env,
            timeout=COMMIT_LOCK_WAIT + 15,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    return result.returncode == 0
