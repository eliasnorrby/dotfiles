#!/usr/bin/env bash

# Plumbing for checkpointing a Claude Code session into an LLM-maintained wiki
# (an Obsidian vault with a CLAUDE.md schema). The writing itself is done by
# Claude, following the wiki-checkpoint skill; this script covers the parts
# that should be deterministic:
#
#   wiki_checkpoint resolve [--issue KEY] [DIR]
#                                      Which vault and task note does the work
#                                      belong to? By default whatever `wk`
#                                      resolves for DIR (the window's task, the
#                                      worktree's, the branch's issue); --issue
#                                      when the session knows better. Prints
#                                      key=value lines.
#   wiki_checkpoint commit VAULT -- FILE...
#                                      Commit exactly these files, message on
#                                      stdin. Serialized across sessions.
#   wiki_checkpoint friction VAULT SLUG
#                                      File a friction report, body on stdin.
#   wiki_checkpoint mark               Record that this session checkpointed.
#   wiki_checkpoint hook EVENT         Claude Code hook: remind the session to
#                                      checkpoint (post-tool-use,
#                                      user-prompt-submit), note that it ended
#                                      with uncaptured work (session-end), or
#                                      keep the file tools out of a vault's
#                                      private/ and off everything but the
#                                      wiki layer (pre-tool-use).
#
# Nothing here names a vault, a tracker or a company. A session is in scope
# when `wk` can tell which task it belongs to; the vault follows from the
# task's project through wk's configuration.
#
# Several sessions checkpoint into the same vault, so `commit` never sweeps
# the working tree: it commits only the paths it is given, under a lock.
#
# Wired via settings.json:
#   PreToolUse (file tools) -> wiki_checkpoint hook pre-tool-use
#   PostToolUse (Bash)  -> wiki_checkpoint hook post-tool-use
#   UserPromptSubmit    -> wiki_checkpoint hook user-prompt-submit
#   SessionEnd          -> wiki_checkpoint hook session-end

set -uo pipefail

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

# Where the vaults live, from wk's configuration.
vaults_dir() {
  local dir
  dir=$(wk config get defaults.vaults_dir 2>/dev/null) || dir="$HOME/vaults"
  printf '%s' "${dir/#\~/$HOME}"
}

# A session is in scope when it works outside the vaults on something wk can
# resolve to a task, or to an issue a task could be imported for. Local only:
# this runs on every prompt.
in_scope() {
  local dir="$1"
  [ -z "${WIKI_CHECKPOINT_DISABLE:-}" ] || return 1
  [ -d "$dir" ] || return 1
  case "$(cd "$dir" && pwd -P)/" in
    "$(vaults_dir)"/*) return 1 ;;
  esac
  wk resolve --json -C "$dir" 2>/dev/null | jq -e '.ok or (.issue != null)' >/dev/null 2>&1
}

# The issue the session in DIR works on, for the uncaptured-work trail.
session_issue() {
  wk resolve --json -C "$1" 2>/dev/null | jq -r '.issue // empty' 2>/dev/null
}

cmd_resolve() {
  local dir="" issue="" result rc vault
  local -a locator=()

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
  [ -z "$issue" ] || locator=(--issue "$issue")

  # Local first, so this works offline and costs nothing per checkpoint: wk
  # asks the tracker only when there is no task yet, and creates the note
  # when it is missing.
  result=$(wk resolve --ensure --json -C "$dir" "${locator[@]}")
  rc=$?
  if [ "$rc" -eq 2 ]; then
    echo "No task found for $dir (pass --issue KEY if you know it)" >&2
    exit 2
  fi
  [ "$rc" -eq 0 ] || die "$(jq -r '.error.message // "wk resolve failed"' <<<"$result" 2>/dev/null)"

  vault=$(jq -r '.vault // empty' <<<"$result")
  if [ ! -f "$vault/CLAUDE.md" ] || [ ! -d "$vault/wiki" ]; then
    echo "Vault $vault has no wiki schema yet; nothing to checkpoint into" >&2
    exit 3
  fi

  jq -r '"issue=\(.issue // "")", "task=\(.task.uuid)", "vault=\(.vault)", "note=\(.note)"' <<<"$result"
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
    for path in "${paths[@]}"; do
      # The old name of a git mv, or a git rm, is already fully staged and
      # matches nothing git add can see; it still belongs in the pathspec.
      git -C "$vault" add -- "$path" 2>/dev/null && continue
      git -C "$vault" diff --cached --quiet -- "$path" && die "git add failed: $path"
    done
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
    # A vault with a `backup` remote (a bare repository on a synced disk) is
    # pushed after every commit. Local, so it costs milliseconds; a failure
    # must never fail a checkpoint.
    if git -C "$vault" remote get-url backup >/dev/null 2>&1; then
      git -C "$vault" push -q backup HEAD >/dev/null 2>&1 || echo "Warning: push to backup failed" >&2
    fi
  ) 9>"$vault/.git/wiki-checkpoint.lock"
}

cmd_friction() {
  local vault="${1:-}" slug="${2:-}" body file
  [ -n "$vault" ] && [ -d "$vault" ] || die "no such vault: ${vault:-<none>}"
  [ -n "$slug" ] || die "usage: wiki_checkpoint friction VAULT SLUG < body"
  body=$(cat)
  [ -n "$body" ] || die "empty report on stdin"

  slug=$(printf '%s' "$slug" | tr -cs '[:alnum:]' ' ' | sed -e 's/^ *//' -e 's/ *$//' | cut -c1-60)
  mkdir -p "$vault/_meta/friction"
  # One file per report, so reports never contend for the same file.
  local title
  title="$(date '+%Y-%m-%d %H%M%S') $slug"
  file="$vault/_meta/friction/$title.md"
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

# Refuse a tool call. Args: REASON
emit_deny() {
  jq -cn --arg r "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
}

# Where the file tools may write inside a vault: the wiki layer and the files
# that carry it. Everything else in a vault is the owner's. A vault extends the
# list with path prefixes, one per line, in _meta/claude-writable (a vault with
# no wiki yet that keeps a few project notes for Claude, say).
vault_allows_write() {
  local vault="$1" rel="$2" prefix
  case "$rel" in
    wiki/* | dailies/* | _meta/friction/* | index.md | log.md | CLAUDE.md) return 0 ;;
    inbox/*)
      # Only Claude's own digests: a file it creates, or one it marked as a
      # digest. The owner's jots there carry no frontmatter.
      [ -e "$vault/$rel" ] || return 0
      head -n 10 "$vault/$rel" 2>/dev/null | grep -q '^type: digest$'
      return
      ;;
  esac
  [ -f "$vault/_meta/claude-writable" ] || return 1
  while IFS= read -r prefix; do
    prefix="${prefix%/}"
    [ -n "$prefix" ] && [ "${prefix#\#}" = "$prefix" ] || continue
    case "$rel" in
      "$prefix" | "$prefix"/*) return 0 ;;
    esac
  done <"$vault/_meta/claude-writable"
  return 1
}

# The vault boundary, enforced: the file tools may not touch private/ at all,
# and may write only where vault_allows_write says. Bash is not covered, so a
# deliberate move on the owner's say-so still works. Runs on every file tool
# call, so it never asks wk anything beyond where the vaults are.
hook_pre_tool_use() {
  local input="$1" tool path vaults verb vault rel
  tool=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)
  path=$(jq -r '.tool_input | .file_path // .notebook_path // .path // empty' <<<"$input" 2>/dev/null)
  [ -n "$tool" ] && [ -n "$path" ] || return 0
  case "$tool" in
    Write | Edit | MultiEdit | NotebookEdit) verb="write" ;;
    Read | Grep | Glob) verb="read" ;;
    *) return 0 ;;
  esac
  vaults=$(vaults_dir)
  path=$(readlink -m "${path/#\~\//$HOME/}" 2>/dev/null) || return 0
  case "$path/" in
    "$vaults"/*/*) ;;
    *) return 0 ;;
  esac
  rel="${path#"$vaults"/}"
  vault="${rel%%/*}"
  # The vault root itself has no path inside the vault.
  if [ "$rel" = "$vault" ]; then rel=""; else rel="${rel#*/}"; fi
  case "$rel/" in
    private/*)
      emit_deny "This vault's private/ is off limits: never read, written, linted or cited. See the vault's CLAUDE.md."
      return 0
      ;;
  esac
  [ "$verb" = write ] || return 0
  vault_allows_write "$vaults/$vault" "$rel" && return 0
  emit_deny "Your file tools write only to the wiki layer of a vault (wiki/, dailies/, _meta/friction/, index.md, log.md, CLAUDE.md, and your own digests in inbox/); ${rel:-the vault root} is the owner's. If it really must change, that is his call and a git mv or an edit he asks for. See the vault's CLAUDE.md."
}

# Hooks must never get in the way: every path exits 0, and anything unexpected
# is swallowed rather than reported into the session.
cmd_hook() {
  local event="${1:-}" input sid cwd now
  input=$(cat)
  if [ "$event" = pre-tool-use ]; then
    hook_pre_tool_use "$input"
    exit 0
  fi
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
        printf '%s\t%s\t%s\t%s\t%s\n' "$(date -Is)" "$sid" "$(session_issue "$cwd")" "$cwd" \
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
