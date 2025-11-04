#!/usr/bin/env bash

# Count active reminders
REMINDERS_DIR="${TMPDIR:-/tmp}/tmux_reminders"

if [[ ! -d "$REMINDERS_DIR" ]]; then
  echo "0"
  exit 0
fi

count=$(find "$REMINDERS_DIR" -type f -name 'reminder_*' 2>/dev/null | wc -l | tr -d ' ')
echo "${count:-0}"
