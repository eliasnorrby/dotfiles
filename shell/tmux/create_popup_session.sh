#!/usr/bin/env bash

# Accept optional flags and session name suffix
# Usage: create_popup_session [--session=<suffix>] [--global] [--attach-only] [command...]
attach_only=false
session_suffix=""
is_global=false

while [[ "$1" == --* ]]; do
  case "$1" in
    --session=*)
      session_suffix="${1#--session=}"
      shift
      ;;
    --global)
      is_global=true
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

# Get current session and determine base session
current_session="$(tmux display -p '#S')"

# Determine the base session name (handle if we're already in a popup)
if [[ "$current_session" =~ ^_popup_(.+)_(.+)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
elif [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
else
  base_session="$current_session"
fi

# Build session name
if $is_global; then
  # Global popup: _popup_GLOBAL_<suffix>
  if [[ -n "$session_suffix" ]]; then
    session="_popup_GLOBAL_${session_suffix}"
  else
    session="_popup_GLOBAL"
  fi
else
  # Session-scoped popup: _popup_<base_session>[_suffix]
  if [[ -n "$session_suffix" ]]; then
    session="_popup_${base_session}_${session_suffix}"
  else
    session="_popup_${base_session}"
  fi
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
