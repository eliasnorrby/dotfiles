#!/usr/bin/env bash

# Notification script for Claude processing completion
# This script plays a sound and sends a notification when Claude
# finishes processing or requests a user action.
#
# Usage: claude_notification <done|input_required|reset>
#
# Wired to Claude Code hooks via settings.json:
#   - Stop             -> done
#   - Notification     -> input_required
#   - UserPromptSubmit -> reset
#
# Deduplication: when Claude stops it fires `done`, then ~60s later the
# idle timer fires a "waiting for your input" Notification (input_required)
# for the same session. To avoid that duplicate, `done` records a per-session
# marker; an `input_required` arriving while the marker is fresh is suppressed.
# `reset` (on UserPromptSubmit) clears the marker the moment you respond, so a
# genuine mid-turn permission prompt later still notifies.

bell() {
  # If running inside tmux, write bell directly to the pane's TTY
  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    # Get the TTY of the tmux pane
    pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
    if [ -n "$pane_tty" ] && [ -w "$pane_tty" ]; then
      # Write bell character directly to the pane's TTY
      printf '\a' >"$pane_tty" 2>/dev/null || printf '\a'
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
  echo "Usage: $0 <done|input_required|reset>" >&2
  exit 1
fi

notification_type="$1"

# Validate notification type
case "$notification_type" in
  done | input_required | reset) ;;
  *)
    echo "Error: Invalid notification type '$notification_type'" >&2
    echo "Usage: $0 <done|input_required|reset>" >&2
    exit 1
    ;;
esac

# Hooks pass a JSON payload on stdin; use it to key state per session.
hook_json=""
if [ ! -t 0 ]; then
  hook_json="$(cat)"
fi

session_id=""
if [ -n "$hook_json" ] && command -v jq >/dev/null 2>&1; then
  session_id="$(printf '%s' "$hook_json" | jq -r '.session_id // empty' 2>/dev/null)"
fi
[ -z "$session_id" ] && session_id="default"

# Per-session marker recording that Claude is waiting for the user. A stale
# marker (session that ended without a reset) auto-expires after the debounce.
state_dir="${XDG_RUNTIME_DIR:-/tmp}/claude_notification"
marker="$state_dir/${session_id}.waiting"
debounce="${CLAUDE_NOTIFY_DEBOUNCE:-300}"

case "$notification_type" in
  reset)
    # User responded: drop the marker so later prompts notify normally.
    rm -f "$marker"
    exit 0
    ;;
  done)
    mkdir -p "$state_dir"
    date +%s >"$marker"
    ;;
  input_required)
    if [ -f "$marker" ]; then
      marker_ts="$(cat "$marker" 2>/dev/null)"
      now="$(date +%s)"
      if [ -n "$marker_ts" ] && [ "$((now - marker_ts))" -lt "$debounce" ]; then
        # Duplicate of the idle timer right after `done`; stay quiet.
        exit 0
      fi
    fi
    ;;
esac

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
