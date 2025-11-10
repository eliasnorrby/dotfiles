#!/usr/bin/env bash

# Count active reminders (and clean up stale ones)
REMINDERS_DIR="${TMPDIR:-/tmp}/tmux_reminders"

if [[ ! -d "$REMINDERS_DIR" ]]; then
  echo "0"
  exit 0
fi

# Clean up stale reminder files (where at job no longer exists)
for file in "$REMINDERS_DIR"/reminder_*; do
  if [[ -f "$file" ]]; then
    # Check if job ID exists (second line of file)
    job_id=$(sed -n '2p' "$file" 2>/dev/null)
    if [[ -n "$job_id" ]]; then
      # Verify job still exists in at queue
      if ! atq | grep -q "^${job_id}[[:space:]]"; then
        rm -f "$file"
      fi
    fi
  fi
done

count=$(find "$REMINDERS_DIR" -type f -name 'reminder_*' 2>/dev/null | wc -l | tr -d ' ')
echo "${count:-0}"
