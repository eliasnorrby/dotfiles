#!/usr/bin/env bash

# Accept optional session name suffix as first argument
# Usage: tmux_popup [session_suffix] [command...]
if [[ "$1" == --session=* ]]; then
  session_suffix="${1#--session=}"
  shift
else
  session_suffix=""
fi

# Build session name: _popup_<current_session>[_suffix]
current_session="$(tmux display -p '#S')"
if [[ -n "$session_suffix" ]]; then
  session="_popup_${current_session}_${session_suffix}"
else
  session="_popup_${current_session}"
fi

if ! tmux has -t "$session" 2>/dev/null; then
  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' "${@}")"
  tmux set-option -s -t "$session_id" key-table popup
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  session="$session_id"
fi

exec tmux attach -t "$session" >/dev/null
