#!/bin/sh

# Find a session with alerts, switch to it, and select a window with an alert.

session_with_alert=$(tmux list-sessions -F "#{?session_alerts,#S,}" | grep -v -m 1 "^$")

if [ -z "$session_with_alert" ]; then
  tmux display-message "No windows with alerts"
  exit 0
fi

tmux switch-client -t "$session_with_alert"

# If the alert is in the session's active window, next-window -a will fail. But
# that's okay, because we're already where we want to be.
tmux next-window -a || :
