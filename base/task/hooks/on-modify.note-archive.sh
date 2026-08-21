#!/usr/bin/env bash

# taskwarrior on-modify hook: file a task's note into the archive when the
# task is closed, and bring it back if the task is reopened.
#
# stdin carries two JSON lines (original, then modified); stdout must carry
# exactly the modified task. Note handling is therefore best-effort: every
# failure path still emits valid JSON, so a problem with the vault can never
# block a task modification. That is also why `set -e` is deliberately absent.
#
# No vault map is needed here. Unlike task_note, this hook only has to *find*
# an existing note, never decide where a new one goes, so it searches every
# vault -- which keeps it working under the .desktop launcher's bare
# environment.
#
# Known gap: `task undo` does not reach this hook. Undo appends inverse
# operations at the storage layer instead of routing a task through the
# command layer, so no before/after pair is ever built and no on-modify fires
# (there is no on-undo hook either). It reverts the `note` UDA we set, because
# that is recorded in the operation log, but not the file move, which is not.
# A note can therefore sit in archive/ while its task is open. Nothing breaks
# -- the uuid scan still finds it and the next real status change corrects the
# location -- so this is left uncorrected by choice. Not firing hooks at the
# operation layer is also what stops a synced change from re-running this hook
# on every replica.

vaults_dir="${TASK_NOTE_VAULTS_DIR:-$HOME/vaults}"
notes_subdir="${TASK_NOTE_SUBDIR:-tasks}"
archive_subdir="${TASK_NOTE_ARCHIVE_SUBDIR:-archive}"

emit() {
  printf '%s\n' "$1"
  exit 0
}

read -r original || exit 0
read -r modified || emit "$original"

[ -n "$modified" ] || emit "$original"
command -v jq >/dev/null 2>&1 || emit "$modified"
[ -d "$vaults_dir" ] || emit "$modified"

old_status=$(printf '%s' "$original" | jq -r '.status // empty' 2>/dev/null)
new_status=$(printf '%s' "$modified" | jq -r '.status // empty' 2>/dev/null)
uuid=$(printf '%s' "$modified" | jq -r '.uuid // empty' 2>/dev/null)
note_rel=$(printf '%s' "$modified" | jq -r '.note // empty' 2>/dev/null)

# Only a status transition is interesting; everything else passes straight
# through, which keeps the common edit path free of any vault I/O.
[ -n "$uuid" ] && [ "$old_status" != "$new_status" ] || emit "$modified"

is_closed() {
  case "$1" in
    completed | deleted) return 0 ;;
    *) return 1 ;;
  esac
}

if is_closed "$new_status" && ! is_closed "$old_status"; then
  direction=archive
elif is_closed "$old_status" && ! is_closed "$new_status"; then
  direction=restore
else
  emit "$modified"
fi

# Prefer the cached path, then fall back to a uuid scan so a note renamed
# inside Obsidian is still found.
find_note() {
  local candidate
  if [ -n "$note_rel" ]; then
    for candidate in "$vaults_dir"/*/"$note_rel".md; do
      if [ -f "$candidate" ]; then
        printf '%s' "$candidate"
        return
      fi
    done
  fi
  candidate=$(grep -rlFx "task: $uuid" "$vaults_dir"/*/"$notes_subdir" \
    --include='*.md' 2>/dev/null | head -1)
  [ -n "$candidate" ] && printf '%s' "$candidate"
}

# Set a frontmatter key, inserting it before the closing delimiter when the
# note does not carry it yet. Confined to the frontmatter block so a
# matching line in the note body is left alone.
set_frontmatter() {
  local file="$1" key="$2" value="$3" tmp
  tmp="$file.tmp.$$"
  awk -v k="$key" -v v="$value" '
    BEGIN { fm = 0; seen = 0 }
    NR == 1 && $0 == "---" { fm = 1; print; next }
    fm == 1 && $0 == "---" { if (!seen) print k ": " v; fm = 2; print; next }
    fm == 1 && index($0, k ": ") == 1 { print k ": " v; seen = 1; next }
    { print }
  ' "$file" >"$tmp" 2>/dev/null
  if [ -s "$tmp" ]; then
    mv "$tmp" "$file" 2>/dev/null || rm -f "$tmp"
  else
    rm -f "$tmp"
  fi
}

note_path=$(find_note)
[ -n "$note_path" ] || emit "$modified"

# Peel the vault root off the discovered path so the note stays in its own
# vault rather than being pulled into a default one.
rest="${note_path#"$vaults_dir"/}"
vault="${rest%%/*}"
vault_dir="$vaults_dir/$vault"
base=$(basename "$note_path")

if [ "$direction" = archive ]; then
  dest_dir="$vault_dir/$notes_subdir/$archive_subdir"
else
  dest_dir="$vault_dir/$notes_subdir"
fi

mkdir -p "$dest_dir" 2>/dev/null || emit "$modified"
dest="$dest_dir/$base"

if [ "$note_path" != "$dest" ]; then
  mv "$note_path" "$dest" 2>/dev/null || emit "$modified"
fi

if [ "$direction" = archive ]; then
  set_frontmatter "$dest" status "done"
  set_frontmatter "$dest" closed "$(date +%F)"
else
  set_frontmatter "$dest" status active
fi

# Rewrite the cached path in the task we hand back, rather than shelling out
# to `task` from inside a hook.
new_rel="${dest#"$vault_dir"/}"
new_rel="${new_rel%.md}"
updated=$(printf '%s' "$modified" | jq -c --arg n "$new_rel" '.note = $n' 2>/dev/null)
[ -n "$updated" ] && emit "$updated"

emit "$modified"
