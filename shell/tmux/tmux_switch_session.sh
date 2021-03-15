#!/bin/sh

# Usage: tmux_switch_session [number]

client=$(tmux list-clients -F "#{client_name}" | head -1)
session=$(tmux ls -F "#{=-1:session_id} #S" | grep "$1" | cut -d " " -f 2)
if [ -z "$session" ] || [ -z "$client" ]; then
  exit
fi
tmux switch-client -c "$client" -t "$session"
