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

from .errors import WkError

FRONTMATTER_BYTES = 4096

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
    recognition: these names are meant to be read in Obsidian's file list."""
    slug = re.sub(r"[/:\\]", "-", text)
    slug = re.sub(r"\s+", " ", slug).strip()
    return slug[:60].rstrip()


def _links_task(path, uuid):
    try:
        with open(path, "rb") as handle:
            head = handle.read(FRONTMATTER_BYTES).decode("utf-8", "replace")
    except OSError:
        return False
    lines = head.splitlines()
    if not lines or lines[0] != "---":
        return False
    for line in lines[1:]:
        if line == "---":
            return False
        if line == f"task: {uuid}":
            return True
    return False


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
    match = re.search(r"\b([A-Z]+-\d+)\b", task.get("description", ""))
    return match.group(1) if match else None


def create(config, vault_path, task):
    directory = os.path.join(vault_path, subdir_for_vault(config, vault_path))
    description = task.get("description", "")
    issue = issue_of(task)
    today = datetime.date.today().isoformat()

    # An issue key is the strongest identifier available, so it leads the
    # filename; otherwise fall back to the date convention used elsewhere.
    if issue:
        rest = slugify(re.sub(rf"^{re.escape(issue)}[\s:._-]*", "", description))
        title = f"{issue} {rest}".strip()
    else:
        title = f"{today} {slugify(description)}".strip()

    os.makedirs(directory, exist_ok=True)
    path = os.path.join(directory, f"{title}.md")
    suffix = 2
    while os.path.exists(path):
        path = os.path.join(directory, f"{title} ({suffix}).md")
        suffix += 1

    frontmatter = [f"task: {task['uuid']}"]
    if issue:
        frontmatter.append(f"issue: {issue}")
    if task.get("project"):
        frontmatter.append(f"project: {task['project']}")
    frontmatter += [f"created: {today}", "status: active"]

    with open(path, "x", encoding="utf-8") as handle:
        # The heading is the file name, so heading and link target agree.
        handle.write(TEMPLATE.format(frontmatter="\n".join(frontmatter), title=title, space=" "))
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


# -- archiving -----------------------------------------------------------


def set_frontmatter(path, values):
    """Set frontmatter keys, inserting them before the closing delimiter when
    the note does not carry them yet. Confined to the frontmatter block so a
    matching line in the note body is left alone."""
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
        line = f"{key}: {value}"
        for index, existing in enumerate(block):
            if existing.startswith(f"{key}: "):
                block[index] = line
                break
        else:
            block.append(line)
    temporary = f"{path}.tmp.{os.getpid()}"
    with open(temporary, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines[:1] + block + lines[end:]))
    os.replace(temporary, path)


def move_for_status(config, task, closed):
    """File a closed task's note into the archive, or bring it back. Returns
    the note's new vault-relative path (no extension), or None when there is
    no note."""
    path = find_anywhere(config, task)
    if not path:
        return None
    vault_path = vault_of(config, path)
    directory = os.path.join(vault_path, subdir_for_vault(config, vault_path))
    if closed:
        directory = os.path.join(directory, config.archive_subdir)
    os.makedirs(directory, exist_ok=True)
    destination = os.path.join(directory, os.path.basename(path))
    if path != destination:
        if os.path.exists(destination):
            return None
        os.rename(path, destination)
    if closed:
        today = datetime.date.today().isoformat()
        set_frontmatter(destination, {"status": "done", "closed": today})
    else:
        set_frontmatter(destination, {"status": "active"})
    return os.path.splitext(os.path.relpath(destination, vault_path))[0]
