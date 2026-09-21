#!/usr/bin/env bash

# Plumbing for checkpointing a Claude Code session into an LLM-maintained wiki
# (an Obsidian vault with a CLAUDE.md schema). The writing itself is done by
# Claude, following the wiki-checkpoint skill; this script covers the parts
# that should be deterministic:
#
#   wiki_checkpoint resolve [--issue KEY] [DIR]
#                                      Which vault and task note does the work
#                                      belong to? By default the issue on DIR's
#                                      branch; --issue when the session knows
#                                      better (an investigation worked on from
#                                      another branch). Prints key=value lines.
#   wiki_checkpoint commit VAULT -- FILE...
#                                      Commit exactly these files, message on
#                                      stdin. Serialized across sessions.
#   wiki_checkpoint friction VAULT SLUG
#                                      File a friction report, body on stdin.
#   wiki_checkpoint mark               Record that this session checkpointed.
#   wiki_checkpoint hook EVENT         Claude Code hook: remind the session to
#                                      checkpoint (post-tool-use,
#                                      user-prompt-submit) or note that it ended
#                                      with uncaptured work (session-end).
#
# Nothing here names a vault, a tracker or a company. A session is in scope
# when its branch carries an issue key; the vault follows from the task's
# project through task_note's own mapping.
#
# Several sessions checkpoint into the same vault, so `commit` never sweeps
# the working tree: it commits only the paths it is given, under a lock.
#
# Wired via settings.json:
#   PostToolUse (Bash)  -> wiki_checkpoint hook post-tool-use
#   UserPromptSubmit    -> wiki_checkpoint hook user-prompt-submit
#   SessionEnd          -> wiki_checkpoint hook session-end

set -uo pipefail

vaults_dir="${TASK_NOTE_VAULTS_DIR:-$HOME/vaults}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/wiki-checkpoint"
# Remind after this many prompts without a checkpoint, but no more often than
# this many seconds.
min_prompts="${WIKI_CHECKPOINT_MIN_PROMPTS:-8}"
min_interval="${WIKI_CHECKPOINT_MIN_INTERVAL:-2700}"
# Events like a push come in bursts; one reminder per burst is enough.
event_debounce="${WIKI_CHECKPOINT_EVENT_DEBOUNCE:-300}"
lock_wait="${WIKI_CHECKPOINT_LOCK_WAIT:-30}"

die() {
  echo "Error: $*" >&2
  exit 1
}

# Print the issue key carried by DIR's branch, uppercased; empty when there is
# none. Deliberately the branch only: the clipboard is no guide to what a
# session is working on.
branch_issue() {
  local dir="$1" branch
  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null) || return 0
  if [[ "$branch" =~ (^|[^A-Za-z0-9])([A-Za-z][A-Za-z0-9]*-[0-9]+)($|[^0-9]) ]]; then
    printf '%s' "${BASH_REMATCH[2]^^}"
  fi
}

# A session is in scope when it works on an issue branch outside the vaults.
in_scope() {
  local dir="$1"
  [ -z "${WIKI_CHECKPOINT_DISABLE:-}" ] || return 1
  [ -d "$dir" ] || return 1
  case "$(cd "$dir" && pwd -P)/" in
    "$vaults_dir"/*) return 1 ;;
  esac
  [ -n "$(branch_issue "$dir")" ]
}

# Print the uuid of the task carrying ISSUE, preferring an open one.
task_for_issue() {
  local json
  json=$(task rc.context= rc.verbose=nothing "issue:$1" export 2>/dev/null)
  jq -r --arg i "$1" '
      [ .[] | select(.issue == $i) ]
      | sort_by(if .status == "pending" or .status == "waiting" then 0 else 1 end, .entry)
      | first | .uuid // empty
    ' <<<"$json" 2>/dev/null
}

cmd_resolve() {
  local dir="" issue="" uuid note vault rest

  while [ $# -gt 0 ]; do
    case "$1" in
      --issue)
        issue="${2^^}"
        shift 2
        ;;
      *)
        dir="$1"
        shift
        ;;
    esac
  done
  dir="${dir:-$PWD}"

  [ -n "$issue" ] || issue=$(branch_issue "$dir")
  if [ -z "$issue" ]; then
    echo "No issue key on the branch in $dir (pass --issue KEY if you know it)" >&2
    exit 2
  fi

  # Local first, so this works offline and costs nothing per checkpoint. The
  # tracker is only asked when there is no task yet.
  uuid=$(task_for_issue "$issue")
  if [ -z "$uuid" ]; then
    task_import_issue "$issue" >/dev/null 2>&1 || true
    uuid=$(task_for_issue "$issue")
  fi
  [ -n "$uuid" ] || die "no task for $issue, and importing it failed"

  note=$(task_note ${TASK_NOTE_PROJECT_VAULTS:+--vault-map "$TASK_NOTE_PROJECT_VAULTS"} \
    --print "$uuid") || die "could not find or create a note for $issue"

  rest="${note#"$vaults_dir"/}"
  vault="$vaults_dir/${rest%%/*}"
  if [ ! -f "$vault/CLAUDE.md" ] || [ ! -d "$vault/wiki" ]; then
    echo "Vault $vault has no wiki schema yet; nothing to checkpoint into" >&2
    exit 3
  fi

  printf 'issue=%s\ntask=%s\nvault=%s\nnote=%s\n' "$issue" "$uuid" "$vault" "$note"
}

cmd_commit() {
  local vault="${1:-}" message
  [ -n "$vault" ] && [ -d "$vault/.git" ] || die "not a git repository: ${vault:-<none>}"
  shift
  [ "${1:-}" = "--" ] && shift
  [ $# -gt 0 ] || die "no files given; this command never commits the whole tree"

  message=$(cat)
  [ -n "$message" ] || die "empty commit message on stdin"

  local -a paths=()
  local path
  for path in "$@"; do
    case "$path" in
      "$vault"/*) path="${path#"$vault"/}" ;;
      /*) die "outside the vault: $path" ;;
    esac
    paths+=("$path")
  done

  ( 
    flock -w "$lock_wait" 9 || die "another checkpoint held the commit lock for over ${lock_wait}s"
    git -C "$vault" add -- "${paths[@]}" || die "git add failed"
    if git -C "$vault" diff --cached --quiet -- "${paths[@]}"; then
      echo "Nothing to commit in the given files (already committed, perhaps by another session)"
      exit 0
    fi
    # The pathspec limits the commit to these files even if something else
    # happens to be staged.
    if ! git -C "$vault" commit -q -F - -- "${paths[@]}" <<<"$message"; then
      die "git commit failed"
    fi
    git -C "$vault" log -1 --format='Committed %h %s'
  ) 9>"$vault/.git/wiki-checkpoint.lock"
}

cmd_friction() {
  local vault="${1:-}" slug="${2:-}" body file
  [ -n "$vault" ] && [ -d "$vault" ] || die "no such vault: ${vault:-<none>}"
  [ -n "$slug" ] || die "usage: wiki_checkpoint friction VAULT SLUG < body"
  body=$(cat)
  [ -n "$body" ] || die "empty report on stdin"

  slug=$(printf '%s' "$slug" | tr -cs '[:alnum:]' ' ' | sed -e 's/^ *//' -e 's/ *$//' | cut -c1-60)
  mkdir -p "$vault/friction"
  # One file per report, so reports never contend for the same file.
  local title
  title="$(date '+%Y-%m-%d %H%M%S') $slug"
  file="$vault/friction/$title.md"
  {
    echo '---'
    echo 'type: friction'
    echo "created: $(date +%F)"
    echo "session: ${CLAUDE_CODE_SESSION_ID:-unknown}"
    echo "cwd: $PWD"
    echo 'status: open'
    echo '---'
    echo
    echo "# $title"
    echo
    printf '%s\n' "$body"
  } >"$file"

  local message
  message=$(printf 'friction: %s\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' "$slug")
  cmd_commit "$vault" -- "$file" <<<"$message" >/dev/null 2>&1 || true
  printf '%s\n' "$file"
}

state_get() {
  cat "$state_dir/$1.$2" 2>/dev/null || echo 0
}

state_set() {
  mkdir -p "$state_dir"
  printf '%s' "$3" >"$state_dir/$1.$2"
}

cmd_mark() {
  local sid="${CLAUDE_CODE_SESSION_ID:-}"
  [ -n "$sid" ] || die "CLAUDE_CODE_SESSION_ID is not set; run this from Claude's Bash tool"
  state_set "$sid" last "$(date +%s)"
  state_set "$sid" prompts 0
  echo "Checkpoint recorded"
}

# Hand a reminder back to the session. Args: EVENT_NAME TEXT
emit_context() {
  jq -cn --arg e "$1" --arg c "$2" \
    '{hookSpecificOutput: {hookEventName: $e, additionalContext: $c}}'
}

reminder_text() {
  # shellcheck disable=SC2016 # the backticks are markdown, not a command
  printf '%s %s' "$1" \
    'Checkpoint this session into the wiki now with the wiki-checkpoint skill (briefly, without interrupting the task at hand), unless nothing worth keeping has happened since the last checkpoint — in that case just run `wiki_checkpoint mark`.'
}

# Hooks must never get in the way: every path exits 0, and anything unexpected
# is swallowed rather than reported into the session.
cmd_hook() {
  local event="${1:-}" input sid cwd now
  input=$(cat)
  sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
  cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
  [ -n "$sid" ] && [ -n "$cwd" ] || exit 0
  now=$(date +%s)

  case "$event" in
    user-prompt-submit)
      in_scope "$cwd" || exit 0
      local prompts last reminded first since
      [ -f "$state_dir/$sid.first" ] || state_set "$sid" first "$now"
      prompts=$(($(state_get "$sid" prompts) + 1))
      state_set "$sid" prompts "$prompts"
      last=$(state_get "$sid" last)
      reminded=$(state_get "$sid" reminded)
      first=$(state_get "$sid" first)
      since=$last
      [ "$reminded" -gt "$since" ] && since=$reminded
      [ "$first" -gt "$since" ] && since=$first
      if [ "$prompts" -ge "$min_prompts" ] && [ $((now - since)) -ge "$min_interval" ]; then
        state_set "$sid" reminded "$now"
        emit_context UserPromptSubmit \
          "$(reminder_text "It has been a while ($prompts prompts) since this session was last checkpointed.")"
      fi
      ;;
    post-tool-use)
      local command
      command=$(jq -r 'select(.tool_name == "Bash") | .tool_input.command // empty' <<<"$input" 2>/dev/null)
      [ -n "$command" ] || exit 0
      [[ "$command" =~ (^|[\;\&\|[:space:]])(gh[[:space:]]+pr[[:space:]]+(create|merge)|git[[:space:]]+push)([[:space:]]|$) ]] || exit 0
      in_scope "$cwd" || exit 0
      [ $((now - $(state_get "$sid" reminded))) -ge "$event_debounce" ] || exit 0
      state_set "$sid" reminded "$now"
      emit_context PostToolUse \
        "$(reminder_text "You just ran \`${BASH_REMATCH[2]}\`, a natural point to record where the work stands.")"
      ;;
    session-end)
      # No model involved: just leave a trail so a later backfill can pick up
      # sessions that ended with work the wiki never saw.
      if [ "$(state_get "$sid" prompts)" -gt 0 ] && in_scope "$cwd"; then
        mkdir -p "$state_dir"
        printf '%s\t%s\t%s\t%s\t%s\n' "$(date -Is)" "$sid" "$(branch_issue "$cwd")" "$cwd" \
          "$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)" >>"$state_dir/uncaptured.tsv"
      fi
      rm -f "$state_dir/$sid".{first,last,prompts,reminded}
      ;;
  esac
  exit 0
}

[ $# -ge 1 ] || die "usage: wiki_checkpoint resolve|commit|friction|mark|hook ..."

sub="$1"
shift
case "$sub" in
  resolve) cmd_resolve "$@" ;;
  commit) cmd_commit "$@" ;;
  friction) cmd_friction "$@" ;;
  mark) cmd_mark "$@" ;;
  hook) cmd_hook "$@" ;;
  *) die "unknown subcommand: $sub" ;;
esac
