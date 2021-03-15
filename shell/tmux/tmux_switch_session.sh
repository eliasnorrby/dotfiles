#!/bin/sh

# Usage: tmux_switch_session [number]

client=$(tmux list-clients -F "#{client_name}" | head -1)
session=$(tmux list-sessions -F "#S" | sed -n "${1}p")
if [ -z "$session" ] || [ -z "$client" ]; then
  exit
fi
tmux switch-client -c "$client" -t "$session"
