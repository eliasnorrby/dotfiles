#!/usr/bin/env bash

# Accept optional flags and session name suffix
# Usage: tmux_popup [--session=<suffix>] [--attach-only] [command...]
attach_only=false
session_suffix=""

while [[ "$1" == --* ]]; do
  case "$1" in
    --session=*)
      session_suffix="${1#--session=}"
      shift
      ;;
    --attach-only)
      attach_only=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Build session name: _popup_<current_session>[_suffix]
current_session="$(tmux display -p '#S')"
if [[ -n "$session_suffix" ]]; then
  session="_popup_${current_session}_${session_suffix}"
else
  session="_popup_${current_session}"
fi

if ! tmux has -t "$session" 2>/dev/null; then
  # If --attach-only is set, don't create a new session
  if $attach_only; then
    exit 0
  fi

  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' "${@}")"
  tmux set-option -s -t "$session_id" key-table popup
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  session="$session_id"
fi

exec tmux attach -t "$session" >/dev/null
