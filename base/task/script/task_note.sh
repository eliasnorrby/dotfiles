#!/usr/bin/env bash

set -eo pipefail

# Open (or create) the note attached to a taskwarrior task.
# Expects a task UUID or ID as argument (taskwarrior-tui passes the UUID).
#
# The note's path is cached in the `note` UDA for fast lookup, but the
# durable link is the `task:` field in the note's frontmatter. A note
# renamed or moved inside Obsidian is recovered by UUID and the stale
# UDA repaired, so renaming in Obsidian never breaks the connection.
#
# Vault selection is driven by the task's project. No vault name is baked
# in; the mapping comes from flags or environment.
#
# Prefer the flags when wiring this into taskwarrior-tui. The TUI is often
# launched straight from a .desktop entry ("kitty -e taskwarrior-tui"),
# which execs the binary without a login shell, so nothing from env.zsh is
# present. Config passed on the shortcut line travels with taskrc and is
# therefore launcher-independent; the environment is only a fallback for
# interactive use.
#
# Usage: task_note [--vault-map work=acme,side=personal]
#                  [--default-vault NAME] [--vaults-dir PATH]
#                  [--subdir NAME] <task-id-or-uuid>

vaults_dir="${TASK_NOTE_VAULTS_DIR:-$HOME/vaults}"
default_vault="${TASK_NOTE_DEFAULT_VAULT:-personal}"
# Comma-separated project=vault pairs, e.g. "work=acme,side=personal".
# Matched against the project root, so "work.backend" maps via "work".
project_vaults="${TASK_NOTE_PROJECT_VAULTS:-}"
notes_subdir="${TASK_NOTE_SUBDIR:-tasks}"

die() {
  echo "Error: $*" >&2
  exit 1
}

vault_for_project() {
  local project="${1%%.*}"
  local pairs pair

  if [ -z "$project" ]; then
    printf '%s' "$default_vault"
    return
  fi

  IFS=',' read -ra pairs <<<"$project_vaults"
  for pair in "${pairs[@]}"; do
    if [ -n "$pair" ] && [ "${pair%%=*}" = "$project" ]; then
      printf '%s' "${pair#*=}"
      return
    fi
  done

  printf '%s' "$default_vault"
}

# Make a description safe for a filename without mangling it beyond
# recognition -- these names are meant to be read in Obsidian's file list.
slugify() {
  local slug
  slug=$(printf '%s' "$1" | sed -E 's#[/:\\]#-#g; s/[[:space:]]+/ /g; s/^ +//; s/ +$//')
  printf '%s' "${slug:0:60}"
}

# Locate an existing note, preferring the cached path and falling back to
# a UUID scan when the note has been renamed out from under us.
resolve_note() {
  local vault_path="$1" uuid="$2" note_rel="$3"
  local candidate

  if [ -n "$note_rel" ] && [ -f "$vault_path/$note_rel.md" ]; then
    printf '%s' "$vault_path/$note_rel.md"
    return
  fi

  candidate=$(grep -rlFx "task: $uuid" "$vault_path/$notes_subdir" \
    --include='*.md' 2>/dev/null | head -1) || true
  if [ -n "$candidate" ]; then
    printf '%s' "$candidate"
  fi
}

create_note() {
  local vault_path="$1" uuid="$2" description="$3" project="$4" issue="$5"
  local dir="$vault_path/$notes_subdir"
  local title path suffix=2

  # An issue key is the strongest identifier available, so it leads the
  # filename; otherwise fall back to the date convention used elsewhere.
  if [ -n "$issue" ]; then
    # Drop a leading key from the description so it isn't repeated.
    local rest
    rest=$(slugify "$(printf '%s' "$description" | sed -E "s/^${issue}[[:space:]:._-]*//")")
    title="$issue${rest:+ $rest}"
  else
    title="$(date +%F) $(slugify "$description")"
  fi

  mkdir -p "$dir"
  path="$dir/$title.md"
  while [ -e "$path" ]; do
    path="$dir/$title ($suffix).md"
    suffix=$((suffix + 1))
  done

  {
    echo '---'
    echo "task: $uuid"
    if [ -n "$issue" ]; then
      echo "issue: $issue"
    fi
    if [ -n "$project" ]; then
      echo "project: $project"
    fi
    echo "created: $(date +%F)"
    echo 'status: active'
    echo '---'
    echo
    echo "# $description"
    echo
    echo '## Plan'
    echo
    echo '- [ ] '
    echo
    echo '## Findings'
    echo
  } >"$path"

  printf '%s' "$path"
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --vault-map)
        project_vaults="$2"
        shift 2
        ;;
      --default-vault)
        default_vault="$2"
        shift 2
        ;;
      --vaults-dir)
        vaults_dir="$2"
        shift 2
        ;;
      --subdir)
        notes_subdir="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        die "unknown option: $1"
        ;;
      *)
        break
        ;;
    esac
  done

  if [ $# -eq 0 ]; then
    die "no task UUID provided"
  fi

  local task_data
  task_data=$(task "$1" export 2>/dev/null) || true
  if [ -z "$task_data" ] || [ "$task_data" = "[]" ]; then
    die "task not found: $1"
  fi

  local uuid description project issue note_rel
  uuid=$(jq -r '.[0].uuid' <<<"$task_data")
  description=$(jq -r '.[0].description // empty' <<<"$task_data")
  project=$(jq -r '.[0].project // empty' <<<"$task_data")
  issue=$(jq -r '.[0].issue // empty' <<<"$task_data")
  note_rel=$(jq -r '.[0].note // empty' <<<"$task_data")

  # Pick up an issue key written straight into the description.
  if [ -z "$issue" ] && [[ "$description" =~ ([A-Z]+-[0-9]+) ]]; then
    issue="${BASH_REMATCH[1]}"
  fi

  local vault vault_path
  vault=$(vault_for_project "$project")
  vault_path="$vaults_dir/$vault"
  [ -d "$vault_path" ] || die "vault not found: $vault_path"

  local note_path
  note_path=$(resolve_note "$vault_path" "$uuid" "$note_rel")
  if [ -z "$note_path" ]; then
    note_path=$(create_note "$vault_path" "$uuid" "$description" "$project" "$issue")
  fi

  local cached="${note_path#"$vault_path"/}"
  cached="${cached%.md}"
  if [ "$cached" != "$note_rel" ]; then
    task "$uuid" modify note:"$cached" >/dev/null 2>&1 || true
  fi

  exec "${EDITOR:-nvim}" "$note_path"
}

main "$@"
