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
#   wiki_checkpoint sweep [--min-age SECONDS] [--vault DIR]
#                                      Commit what has settled in every vault
#                                      (the owner's jots and moves, hook-made
#                                      archive moves; where sessions write,
#                                      edits only after four hours). Run from
#                                      a timer.
#   wiki_checkpoint friction VAULT SLUG
#                                      File a friction report, body on stdin.
#   wiki_checkpoint mark               Record that this session checkpointed.
#   wiki_checkpoint usage [--since DATE] [--vault NAME] [--write]
#                                      How sessions use the wiki: which pages
#                                      they read, how many never looked, and
#                                      what their task notes say helped or was
#                                      wrong. Markdown on stdout; --write puts
#                                      it in <vault>/_meta/usage/ instead.
#   wiki_checkpoint hook EVENT         Claude Code hook: hand a work session a
#                                      map of its vault's hubs (session-start),
#                                      remind the session to checkpoint
#                                      (post-tool-use, user-prompt-submit),
#                                      note that it ended with uncaptured work
#                                      (session-end), keep the file tools out
#                                      of a vault's private/ and off
#                                      everything but the wiki layer
#                                      (pre-tool-use), and log every read of a
#                                      wiki page (pre-tool-use, post-tool-use).
#
# Nothing here names a vault, a tracker or a company. A session is in scope
# when `wk` can tell which task it belongs to; the vault follows from the
# task's project through wk's configuration.
#
# Several sessions checkpoint into the same vault, so `commit` never sweeps
# the working tree: it commits only the paths it is given, under a lock.
#
# Wired via settings.json:
#   SessionStart        -> wiki_checkpoint hook session-start
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
# One line per work session started and per wiki page read, for `usage`.
usage_log="$state_dir/usage.tsv"

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

# The vault the task in DIR belongs to (the task's project, through wk's
# configuration), without creating a note or asking the tracker.
session_vault() {
  local project name
  project=$(wk resolve --json -C "$1" 2>/dev/null | jq -r '.task.project // empty' 2>/dev/null)
  [ -n "$project" ] || return 1
  name=$(wk config get "projects.$project.vault" 2>/dev/null) || return 1
  [ -n "$name" ] && [ -f "$(vaults_dir)/$name/index.md" ] || return 1
  printf '%s/%s' "$(vaults_dir)" "$name"
}

# The session's issue, looked up once and remembered.
cached_issue() {
  local sid="$1" cwd="$2" f="$state_dir/$1.issue"
  if [ ! -f "$f" ]; then
    mkdir -p "$state_dir"
    session_issue "$cwd" >"$f" 2>/dev/null
  fi
  cat "$f" 2>/dev/null
}

# Append to the usage log. Args: EVENT SID CWD TOOL VAULT PATH
log_usage() {
  mkdir -p "$state_dir"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date -Is)" "$1" "$2" "$(cached_issue "$2" "$3")" \
    "$4" "$5" "$6" "$3" >>"$usage_log"
}

# Log a read of a vault file when it is wiki content. Args: SID CWD TOOL ABSPATH
log_wiki_read() {
  local vaults rel vault
  vaults=$(vaults_dir)
  case "$4/" in
    "$vaults"/*/*) ;;
    *) return 0 ;;
  esac
  rel="${4#"$vaults"/}"
  vault="${rel%%/*}"
  rel="${rel#*/}"
  case "$rel" in
    wiki | wiki/* | index.md | dailies/*) log_usage read "$1" "$2" "$3" "$vault" "$rel" ;;
  esac
}

# What a work session is handed at start: where its wiki is and the list of
# hubs and topics, which each list their pages. The full index is a read away.
wiki_map() {
  local vault="$1" issue="$2" topics
  topics=$(awk '/^## Topics/{on=1; next} /^## /{if(on) exit} on' "$vault/index.md")
  cat <<EOF
This work has a wiki: $vault (an Obsidian vault; its CLAUDE.md is the schema).
Before you investigate anything with history (a system, a customer, an external
API, an incident, a past decision), look it up there instead of rediscovering
it: the hubs below each list their pages under \`## Pages\`; topics are
$vault/wiki/topics/<Title>.md, pages $vault/wiki/pages/<Title>.md; the entry
index is $vault/index.md, and it links the tasks, people and loose-pages indexes. Open questions and known problems are on
[[Open questions]] and [[Loose ends]]. ${issue:+Your task note: \`wiki_checkpoint resolve\` (issue $issue). }When you
checkpoint, note which pages helped and which were wrong or missing.

Hubs and topics:
$topics
EOF
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


# Commit whatever has settled in a vault: the owner's jots and moves, task
# notes archived by wk's hooks, Obsidian configuration. Nobody should have to
# think about committing. A file is settled when it has not been written to
# for MIN_AGE seconds, which keeps a jot still being typed out of the sweep.
#
# Where sessions write (the paths the pre-tool-use hook lets them write) is
# different: a session may work for an hour and leave a page untouched for most
# of it before its own commit. There the sweep takes moves at once (a deleted
# path whose file name reappears untracked elsewhere, as wk's archive hook
# leaves a task note), and anything else only after SESSION_AGE seconds, by
# which time no session is still holding it: work a session abandoned, or the
# owner's own edits to files sessions may also write.
sweep_vault() {
  local vault="$1" min_age="$2" session_age="$3" now entry status path mtime base i age
  local -a paths=() statuses=() entries=()
  local -A deleted=() moved=()
  now=$(date +%s)
  while IFS= read -r -d '' entry; do
    status="${entry:0:2}"
    path="${entry:3}"
    case "$status" in
      R* | C*)
        # A staged rename or copy carries the original path as a second
        # record. It is a move by definition; take both sides.
        IFS= read -r -d '' entry || true
        paths+=("$entry" "$path")
        continue
        ;;
    esac
    statuses+=("$status")
    entries+=("$path")
    base="${path##*/}"
    case "$status" in
      *D) deleted[$base]=1 ;;
    esac
  done < <(git -C "$vault" status --porcelain -z --untracked-files=all)

  # New files first, so a move's deletion is taken only with its new half.
  for i in "${!entries[@]}"; do
    status="${statuses[$i]}"
    path="${entries[$i]}"
    base="${path##*/}"
    case "$status" in *D) continue ;; esac
    age=$min_age
    if vault_allows_write "$vault" "$path"; then
      [ "$status" = '??' ] && [ -n "${deleted[$base]:-}" ] || age=$session_age
    fi
    mtime=$(stat -c %Y "$vault/$path" 2>/dev/null) || continue
    [ $((now - mtime)) -ge "$age" ] || continue
    paths+=("$path")
    [ "$status" = '??' ] && moved[$base]=1
  done
  for i in "${!entries[@]}"; do
    status="${statuses[$i]}"
    path="${entries[$i]}"
    base="${path##*/}"
    case "$status" in *D) ;; *) continue ;; esac
    # A session's own deletion carries no age; it waits for the session.
    if vault_allows_write "$vault" "$path"; then
      [ -n "${moved[$base]:-}" ] || continue
    fi
    paths+=("$path")
  done
  [ ${#paths[@]} -gt 0 ] || return 0

  local message
  message=$(
    printf 'auto: sweep %s (%d files)\n\n' "$(basename "$vault")" "${#paths[@]}"
    printf '%s\n' "${paths[@]}" | head -n 30
    [ ${#paths[@]} -le 30 ] || echo "…"
  )
  cmd_commit "$vault" -- "${paths[@]}" <<<"$message"
}

cmd_sweep() {
  local min_age="${WIKI_SWEEP_MIN_AGE:-300}" session_age="${WIKI_SWEEP_SESSION_AGE:-14400}" vault only=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --min-age)
        min_age="$2"
        shift 2
        ;;
      --vault)
        only="$2"
        shift 2
        ;;
      *) die "usage: wiki_checkpoint sweep [--min-age SECONDS] [--vault DIR]" ;;
    esac
  done
  if [ -n "$only" ]; then
    [ -d "$only/.git" ] || die "not a git repository: $only"
    sweep_vault "$only" "$min_age" "$session_age"
    return
  fi
  for vault in "$(vaults_dir)"/*/; do
    vault="${vault%/}"
    [ -d "$vault/.git" ] && [ -f "$vault/CLAUDE.md" ] || continue
    sweep_vault "$vault" "$min_age" "$session_age"
  done
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
  if [ "$verb" = read ]; then
    local sid cwd
    sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
    cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
    [ -n "$sid" ] && log_wiki_read "$sid" "$cwd" "$tool" "$path"
    return 0
  fi
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
    session-start)
      local vault
      in_scope "$cwd" || exit 0
      vault=$(session_vault "$cwd") || exit 0
      log_usage start "$sid" "$cwd" "" "${vault##*/}" ""
      emit_context SessionStart "$(wiki_map "$vault" "$(cached_issue "$sid" "$cwd")")"
      ;;
    post-tool-use)
      local command vaults p
      command=$(jq -r 'select(.tool_name == "Bash") | .tool_input.command // empty' <<<"$input" 2>/dev/null)
      [ -n "$command" ] || exit 0
      # Reads through the shell (cat, sed, grep, head) count too. Titles have
      # spaces, so take everything up to the .md.
      vaults=$(vaults_dir)
      if [[ "$command" == *"$vaults/"* || "$command" == *"~/vaults/"* ]]; then
        while IFS= read -r p; do
          [ -n "$p" ] && log_wiki_read "$sid" "$cwd" Bash "${p/#\~\//$HOME/}"
        done < <(grep -oP "(?:\Q$vaults\E|~/vaults)/[^/'\"]+/(?:wiki/[^'\"]*?\.md|index\.md)" <<<"$command" | sort -u)
      fi
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
      rm -f "$state_dir/$sid".{first,last,prompts,reminded,issue}
      ;;
  esac
  exit 0
}

cmd_usage() {
  local since="" vault="" write=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --since) since="$2"; shift 2 ;;
      --vault) vault="$2"; shift 2 ;;
      --write) write=1; shift ;;
      *) die "usage: wiki_checkpoint usage [--since YYYY-MM-DD] [--vault NAME] [--write]" ;;
    esac
  done
  since="${since:-$(date -d '7 days ago' +%F)}"
  local vaults report
  vaults=$(vaults_dir)
  [ -f "$usage_log" ] || die "no usage logged yet ($usage_log)"
  for v in "$vaults"/*/; do
    v="${v%/}"
    [ -f "$v/index.md" ] || continue
    [ -z "$vault" ] || [ "${v##*/}" = "$vault" ] || continue
    report=$(python3 - "$usage_log" "$v" "$since" "$vaults" <<'PY'
import collections, datetime, os, re, sys
log, vault, since, vaults = sys.argv[1:5]
name = os.path.basename(vault)
starts, reads = {}, collections.defaultdict(list)
for line in open(log, encoding="utf-8"):
    f = line.rstrip("\n").split("\t")
    if len(f) < 8 or f[0][:10] < since:
        continue
    ts, ev, sid, issue, tool, v, rel, cwd = f[:8]
    if cwd.startswith(vaults + "/"):
        continue  # sessions maintaining the wiki itself
    if ev == "start" and v == name:
        starts.setdefault(sid, (ts, issue))
    elif ev == "read" and v == name:
        reads[sid].append((ts, tool, rel))
        starts.setdefault(sid, (ts, issue))
own = lambda rel: rel.startswith(("wiki/tasks/", "dailies/"))
n = len(starts)
read_any = [s for s in starts if reads.get(s)]
read_index = [s for s in starts if any(r[2] == "index.md" for r in reads.get(s, []))]
read_pages = [s for s in starts if any(r[2].startswith(("wiki/topics/", "wiki/pages/", "wiki/people/")) for r in reads.get(s, []))]
by_page = collections.Counter()
for s, rs in reads.items():
    for rel in {r[2] for r in rs}:
        if rel.endswith(".md") and not own(rel) and rel != "index.md":
            by_page[rel] += 1
hubs = sorted(f[:-3] for f in os.listdir(os.path.join(vault, "wiki/topics")) if f.endswith(".md"))
unread_hubs = [h for h in hubs if f"wiki/topics/{h}.md" not in by_page]
notes = []
for sub in ("wiki/tasks", "wiki/tasks/archive"):
    d = os.path.join(vault, sub)
    if not os.path.isdir(d):
        continue
    for fn in os.listdir(d):
        if not fn.endswith(".md"):
            continue
        t = open(os.path.join(d, fn), encoding="utf-8").read()
        m = re.search(r"^## Wiki use\n(.*?)(?=^## |\Z)", t, re.S | re.M)
        if not m:
            continue
        for l in m.group(1).splitlines():
            d8 = re.match(r"- (\d{4}-\d{2}-\d{2})", l)
            if d8 and d8.group(1) >= since:
                notes.append((fn[:-3], l[2:].strip()))
pct = lambda k: f"{k} of {n}" + (f" ({100 * k // n} %)" if n else "")
out = [f"# Wiki usage {since} to {datetime.date.today()}", "",
       f"Work sessions in scope of {name}: {n}.", "",
       f"- read any wiki file: {pct(len(read_any))}",
       f"- read index.md: {pct(len(read_index))}",
       f"- read a topic, page or person (not their own task note or a daily): {pct(len(read_pages))}", "",
       "## Most-read pages", ""]
out += [f"- {c} × [[{os.path.basename(p)[:-3]}]]" for p, c in by_page.most_common(25)] or ["- none"]
out += ["", "## Sessions", ""]
for s, (ts, issue) in sorted(starts.items(), key=lambda kv: kv[1][0]):
    rs = reads.get(s, [])
    pages = sorted({os.path.basename(r[2])[:-3] for r in rs if r[2].endswith(".md") and not own(r[2])})
    out.append(f"- {ts[:16]} {issue or '(no issue)'} `{s[:8]}`: {len(rs)} reads" + (f" — {', '.join(pages)}" if pages else ""))
out += ["", "## What task notes say (## Wiki use)", ""]
out += [f"- [[{t}]]: {l}" for t, l in sorted(notes)] or ["- nothing recorded"]
out += ["", f"## Hubs and topics nobody read ({len(unread_hubs)} of {len(hubs)})", "",
        ", ".join(f"[[{h}]]" for h in unread_hubs) or "none"]
print("\n".join(out))
PY
)
    if [ -n "$write" ]; then
      mkdir -p "$v/_meta/usage"
      printf '%s\n' "$report" >"$v/_meta/usage/$(date +%F).md"
      echo "$v/_meta/usage/$(date +%F).md"
    else
      printf '%s\n\n' "$report"
    fi
  done
}

[ $# -ge 1 ] || die "usage: wiki_checkpoint resolve|commit|sweep|friction|mark|usage|hook ..."

sub="$1"
shift
case "$sub" in
  resolve) cmd_resolve "$@" ;;
  commit) cmd_commit "$@" ;;
  sweep) cmd_sweep "$@" ;;
  friction) cmd_friction "$@" ;;
  mark) cmd_mark "$@" ;;
  usage) cmd_usage "$@" ;;
  hook) cmd_hook "$@" ;;
  *) die "unknown subcommand: $sub" ;;
esac
