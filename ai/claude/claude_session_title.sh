#!/usr/bin/env bash

# Name the current Claude Code session from inside the conversation.
#
# Claude cannot run /rename itself, but a UserPromptSubmit hook may return a
# `sessionTitle`, which takes the same path as /rename (persisted as a
# custom-title record, shown in `claude --resume`). So this script has two
# halves:
#
#   claude_session_title set <title>   Queue a title for the current session.
#                                      Run by Claude from the Bash tool, where
#                                      CLAUDE_CODE_SESSION_ID is set.
#   claude_session_title hook          UserPromptSubmit hook: apply the queued
#                                      title, if any, and drop the queue file.
#   claude_session_title show          Print the queued title, if any.
#
# The title therefore lands on the prompt *after* `set`; there is no supported
# way to rename mid-turn. Titles are capped at 200 characters and control
# characters are replaced with spaces, mirroring /rename.
#
# Wired via settings.json:
#   UserPromptSubmit -> claude_session_title hook

set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/session-title"
max_len=200

usage() {
  echo "Usage: $0 set <title> | hook | show" >&2
  exit 1
}

queue_file() {
  local session_id="$1"
  [ -n "$session_id" ] || return 1
  printf '%s/%s' "$state_dir" "$session_id"
}

sanitize() {
  # Collapse control characters and runs of whitespace; trim; truncate.
  printf '%s' "$1" | tr -s '[:cntrl:][:space:]' ' ' | sed -e 's/^ *//' -e 's/ *$//' | cut -c1-"$max_len"
}

[ $# -ge 1 ] || usage

case "$1" in
  set)
    [ $# -ge 2 ] || usage
    shift
    title="$(sanitize "$*")"
    if [ -z "$title" ]; then
      echo "Error: empty title" >&2
      exit 1
    fi
    file="$(queue_file "${CLAUDE_CODE_SESSION_ID:-}")" || {
      echo "Error: CLAUDE_CODE_SESSION_ID is not set; run this from Claude's Bash tool" >&2
      exit 1
    }
    mkdir -p "$state_dir"
    printf '%s\n' "$title" >"$file"
    echo "Session title queued: $title (applied on the next prompt)"
    ;;
  show)
    file="$(queue_file "${CLAUDE_CODE_SESSION_ID:-}")" || exit 0
    [ -f "$file" ] && cat "$file"
    ;;
  hook)
    # Never fail the prompt: any problem here just means no rename.
    hook_json=""
    if [ ! -t 0 ]; then
      hook_json="$(cat)"
    fi
    session_id=""
    if [ -n "$hook_json" ]; then
      session_id="$(printf '%s' "$hook_json" | jq -r '.session_id // empty' 2>/dev/null || true)"
    fi
    file="$(queue_file "$session_id")" || exit 0
    [ -f "$file" ] || exit 0
    title="$(sanitize "$(cat "$file")")"
    rm -f "$file"
    [ -n "$title" ] || exit 0
    jq -cn --arg title "$title" \
      '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", sessionTitle: $title}}'
    ;;
  *)
    usage
    ;;
esac
