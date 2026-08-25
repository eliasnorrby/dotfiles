#!/usr/bin/env bash

set -uo pipefail

# Create a taskwarrior task from an issue/PR reference.
#
# Usage: task_import_issue [--notify] [--wait] [--dry-run] [REFERENCE]
#
# The reference is resolved by issue_resolve, so it may be given explicitly or
# left to the clipboard or the current branch, and may be a Linear key, a
# Linear or GitHub URL, or a bare PR number.
#
# The identifier is kept out of the description and stored in a UDA instead:
# `issue` for Linear, `pr_number`/`pr_repo` for GitHub. task_note reads `issue`
# when naming a note, and the +pr tag hands GitHub tasks to gh_pr_task_sync,
# which will then complete them on merge (and delete them if the PR is closed
# unmerged).
#
# Importing the same reference twice is a no-op: an open task for it is
# reported rather than duplicated, so this is safe to bind to a key.

NOTIFY=false
DRY_RUN=false
WAIT=false

# taskwarrior-tui redraws over a shortcut's output the moment it exits, so
# anything printed from there is invisible without a pause. Same reason
# gh_pr_task_sync takes --wait.
maybe_wait() {
  [ "$WAIT" = true ] || return 0
  read -r -p "Press Enter to continue..." _ || true
}

# Report to stdout, and to the desktop when asked. Args: TITLE BODY [urgency]
report() {
  local title=$1 body=$2 urgency=${3:-normal}
  if [ "$urgency" = critical ]; then
    printf '%s: %s\n' "$title" "$body" >&2
  else
    printf '%s\n' "$body"
  fi
  if [ "$NOTIFY" = true ] && command -v notify-send >/dev/null 2>&1; then
    notify-send -u "$urgency" -a task "$title" "$body"
  fi
}

die() {
  report "Import failed" "$1" critical
  maybe_wait
  exit 1
}

# Print an open task already carrying this reference, as "id<TAB>description".
# Args: TASK_FILTER FIELD VALUE -- the filter narrows, the field/value pair
# confirms, since a UDA filter alone can match across repos.
existing_task() {
  local filter=$1 field=$2 value=$3 json
  json=$(task rc.context= rc.verbose=nothing "$filter" export 2>/dev/null)
  [ -n "$json" ] || return 0
  jq -r --arg f "$field" --arg v "$value" '
    first(
      .[]
      | select(.status == "pending" or .status == "waiting")
      | select((.[$f] | tostring) == $v)
      | "\(.id)\t\(.description)"
    ) // empty
  ' <<<"$json" 2>/dev/null
}

usage() {
  cat <<'EOF'
Usage: task_import_issue [--notify] [--wait] [--dry-run] [REFERENCE]

Create a taskwarrior task from a Linear or GitHub reference. REFERENCE may be
a Linear key, a Linear or GitHub URL, or a bare PR number; when omitted the
clipboard and then the current git branch are tried.

  --notify, -n   also report via notify-send
  --wait, -w     pause before exiting, so output stays readable
  --dry-run      show what would be created without creating it
EOF
}

main() {
  local ref="" result rc id title repo kind existing
  local -a attrs

  while [ $# -gt 0 ]; do
    case "$1" in
      --notify | -n)
        NOTIFY=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --wait | -w)
        WAIT=true
        shift
        ;;
      --help | -h)
        usage
        exit 0
        ;;
      *)
        # taskwarrior-tui appends the selected task's uuid to a shortcut. Skip
        # it so the import still reads the clipboard: a uuid is not a
        # reference, but it can contain one (…a12e-197… parses as E-197).
        if [[ "$1" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
          shift
          continue
        fi
        ref=$1
        shift
        ;;
    esac
  done

  command -v issue_resolve >/dev/null 2>&1 || die "issue_resolve is not on PATH"
  command -v jq >/dev/null 2>&1 || die "jq is not installed"

  # issue_resolve keeps stdout clean on success and reports on stderr, so
  # merging the streams yields either the result or the failure message.
  result=$(issue_resolve --with-repo ${ref:+"$ref"} 2>&1)
  rc=$?
  [ "$rc" -eq 0 ] || die "$result"

  id=${result%%$'\t'*}
  title=${result#*$'\t'}
  repo=${title#*$'\t'}
  title=${title%%$'\t'*}
  [ -n "$title" ] || die "resolved $id but it has no title"

  if [ "${id#\#}" != "$id" ]; then
    kind=github
  else
    kind=linear
  fi

  if [ "$kind" = linear ]; then
    existing=$(existing_task "issue:$id" issue "$id")
    attrs=("issue:$id" "project:work")
  else
    [ -n "$repo" ] || die "could not determine the repo for $id"
    existing=$(existing_task "pr_number:${id#\#}" pr_repo "$repo")
    attrs=("pr_number:${id#\#}" "pr_repo:$repo" "project:work" "+pr")
  fi

  if [ -n "$existing" ]; then
    report "Already imported" "${existing%%$'\t'*}  ${existing#*$'\t'}  [$id]"
    maybe_wait
    exit 0
  fi

  if [ "$DRY_RUN" = true ]; then
    report "Would import" "$id  $title  (${attrs[*]})"
    maybe_wait
    exit 0
  fi

  # Attributes precede `--` so taskwarrior parses them; everything after is
  # taken as the description verbatim, which keeps a title containing a colon
  # or a plus sign from being read as metadata.
  local output
  if ! output=$(task rc.context= rc.verbose=new-id add "${attrs[@]}" -- "$title" 2>&1); then
    die "$output"
  fi

  report "Task added" "$output  [$id]"
  maybe_wait
}

main "$@"
