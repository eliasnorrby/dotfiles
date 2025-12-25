#!/usr/bin/env bash

# Notification script for Claude processing completion
# This script plays a sound and sends a notification when Claude
# finishes processing or requests a user action.

# Usage: claude_notification <done|input_required>

bell() {
  # If running inside tmux, write bell directly to the pane's TTY
  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    # Get the TTY of the tmux pane
    pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
    if [ -n "$pane_tty" ] && [ -w "$pane_tty" ]; then
      # Write bell character directly to the pane's TTY
      printf '\a' >"$pane_tty"  2>/dev/null || printf '\a'
    else
      printf '\a'
    fi
  else
    # Not in tmux, just print bell normally
    printf '\a'
  fi
}

# Validate parameter
if [ $# -ne 1 ]; then
  echo "Usage: $0 <done|input_required>" >&2
  exit 1
fi

notification_type="$1"

# Validate notification type
if [[ "$notification_type" != "done" && "$notification_type" != "input_required" ]]; then
  echo "Error: Invalid notification type '$notification_type'" >&2
  echo "Usage: $0 <done|input_required>" >&2
  exit 1
fi

bell

# Set notification message and sound based on type and platform
if [[ "$notification_type" == "done" ]]; then
  message="Claude is done."
  macos_sound="/System/Library/Sounds/Funk.aiff"
  linux_sound="/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
else
  message="Claude needs your input to continue."
  macos_sound="/System/Library/Sounds/Hero.aiff"
  linux_sound="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
fi

# Send notification
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "Claude" -message "$message"
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "Claude" "$message"
fi

# Play sound
if command -v afplay >/dev/null 2>&1; then
  afplay -v 3 "$macos_sound"
elif command -v paplay >/dev/null 2>&1 && [[ -f "$linux_sound" ]]; then
  paplay "$linux_sound"
fi
