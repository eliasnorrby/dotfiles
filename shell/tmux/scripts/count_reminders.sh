#!/usr/bin/env bash

# Count active reminders (and clean up expired ones)
REMINDERS_DIR="${TMPDIR:-/tmp}/tmux_reminders"

if [[ ! -d "$REMINDERS_DIR" ]]; then
  echo "0"
  exit 0
fi

now=$(date +%s)

# Clean up expired reminder files
for file in "$REMINDERS_DIR"/reminder_*; do
  if [[ -f "$file" ]]; then
    target=$(sed -n '2p' "$file" 2>/dev/null)
    # Remove if target is in the past (already fired)
    if [[ -n "$target" ]] && ((target < now)); then
      rm -f "$file"
    fi
  fi
done

count=$(find "$REMINDERS_DIR" -type f -name 'reminder_*' 2>/dev/null | wc -l | tr -d ' ')
echo "${count:-0}"
