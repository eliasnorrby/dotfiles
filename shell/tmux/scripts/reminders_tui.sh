#!/usr/bin/env bash

# Simple TUI for managing reminders in a tmux popup
# Uses 'at' command for reliable scheduling that survives sleep

REMINDERS_DIR="${TMPDIR:-/tmp}/tmux_reminders"
mkdir -p "$REMINDERS_DIR"

# Function to display an error notification
notify_error() {
  local message="$1"
  terminal-notifier -title "Error" -message "$message" -sound default
}

# Function to send the reminder notification
send_notification() {
  local message="$1"
  terminal-notifier -title "Time's Up!" -message "$message" -timeout 0 -sound default
}

# Function to parse duration/time into at-compatible format
parse_time_for_at() {
  local input="$1"

  # Check if it's an absolute time in HH:MM format
  if [[ "$input" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
    local hour="${BASH_REMATCH[1]}"
    local minute="${BASH_REMATCH[2]}"

    # Validate hour and minute ranges
    if ((hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59)); then
      echo "$hour:$minute"
      return 0
    else
      return 1
    fi
  fi

  # Otherwise, parse as relative duration
  if [[ "$input" =~ ^([0-9]+)([mhd])$ ]]; then
    local num="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2]}"

    case "$unit" in
      m) echo "now + $num minutes" ;;
      h) echo "now + $num hours" ;;
      d) echo "now + $num days" ;;
      *) return 1 ;;
    esac
  else
    return 1
  fi
}

# Function to start a reminder using at
start_reminder() {
  local message="$1"
  local duration="$2"

  local at_time
  if ! at_time=$(parse_time_for_at "$duration"); then
    notify_error "Invalid time/duration: \"$duration\""
    return 1
  fi

  # Create unique ID for this reminder
  local reminder_id="reminder_$$_$(date +%s)_$RANDOM"
  local reminder_file="$REMINDERS_DIR/$reminder_id"

  # Store reminder info with job ID (will be updated after at submission)
  echo "$message" >"$reminder_file"

  # Create a script that will be executed by at
  local at_script
  at_script=$(
    cat <<EOF
terminal-notifier -title "Time's Up!" -message "$message" -timeout 0 -sound default
rm -f "$reminder_file"
EOF
  )

  # Submit to at and capture job ID
  local at_output
  if at_output=$(echo "$at_script" | at "$at_time" 2>&1); then
    # Extract job number from at output (e.g., "job 5 at Tue Nov  4 14:00:00 2025")
    local job_id
    job_id=$(echo "$at_output" | grep -oE 'job [0-9]+' | grep -oE '[0-9]+')

    # Store job ID in the reminder file for tracking
    echo "$job_id" >>"$reminder_file"

    # Inform user
    terminal-notifier -title "Reminder Set" -message "I'll remind you to \"$message\" in $duration." -sound default
    return 0
  else
    notify_error "Failed to schedule reminder: $at_output"
    rm -f "$reminder_file"
    return 1
  fi
}

# Function to count active reminders
count_reminders() {
  # Clean up stale reminder files (where at job no longer exists)
  if [[ -d "$REMINDERS_DIR" ]]; then
    for file in "$REMINDERS_DIR"/reminder_*; do
      if [[ -f "$file" ]]; then
        # Check if job ID exists (second line of file)
        local job_id
        job_id=$(sed -n '2p' "$file" 2>/dev/null)
        if [[ -n "$job_id" ]]; then
          # Verify job still exists in at queue
          if ! atq | grep -q "^${job_id}[[:space:]]"; then
            rm -f "$file"
          fi
        fi
      fi
    done
  fi

  find "$REMINDERS_DIR" -type f -name 'reminder_*' 2>/dev/null | wc -l | tr -d ' '
}

# Function to list active reminders
list_reminders() {
  # First clean up stale entries
  count_reminders >/dev/null

  local count=0
  echo ""
  echo "Active Reminders:"
  echo "================="

  if [[ ! -d "$REMINDERS_DIR" ]] || [[ -z "$(ls -A "$REMINDERS_DIR" 2>/dev/null)" ]]; then
    echo "No active reminders"
  else
    for file in "$REMINDERS_DIR"/reminder_*; do
      if [[ -f "$file" ]]; then
        ((count++))
        local message
        message=$(head -n 1 "$file")
        local job_id
        job_id=$(sed -n '2p' "$file" 2>/dev/null)

        # Get scheduled time from atq
        local time_info=""
        if [[ -n "$job_id" ]]; then
          time_info=$(atq | grep "^${job_id}[[:space:]]" | awk '{print $2, $3, $4, $5}')
        fi

        if [[ -n "$time_info" ]]; then
          echo "$count. $message (at $time_info)"
        else
          echo "$count. $message"
        fi
      fi
    done
  fi
  echo ""
}

# Function to clear all reminders
clear_all_reminders() {
  echo ""
  echo -n "Are you sure you want to clear ALL reminders? (y/N): "
  read -r confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # Remove all at jobs for reminders
    if [[ -d "$REMINDERS_DIR" ]]; then
      for file in "$REMINDERS_DIR"/reminder_*; do
        if [[ -f "$file" ]]; then
          local job_id
          job_id=$(sed -n '2p' "$file" 2>/dev/null)
          if [[ -n "$job_id" ]]; then
            atrm "$job_id" 2>/dev/null
          fi
          rm -f "$file"
        fi
      done
    fi

    echo "All reminders cleared."
    sleep 1
  else
    echo "Cancelled."
    sleep 1
  fi
}

# Main TUI loop
clear
echo "================================"
echo "    Reminders Manager"
echo "================================"
echo ""
echo "Commands:"
echo "  [Enter] - Set a new reminder"
echo "  l       - List active reminders"
echo "  c       - Clear all reminders"
echo "  q       - Quit"
echo ""

while true; do
  list_reminders

  echo -n "Command (Enter/l/c/q): "
  read -r cmd

  case "$cmd" in
    "")
      # Set a new reminder
      echo ""
      echo -n "Remind me to: "
      read -r message

      if [[ -z "$message" ]]; then
        echo "Cancelled"
        continue
      fi

      echo -n "When (e.g., 10m, 1h, 14:30): "
      read -r duration

      if [[ -z "$duration" ]]; then
        echo "Cancelled"
        continue
      fi

      start_reminder "$message" "$duration"
      clear
      echo "Reminder set!"
      echo ""
      ;;

    l | L)
      # Just refresh the list (already shown)
      clear
      ;;

    c | C)
      # Clear all reminders
      clear_all_reminders
      clear
      ;;

    q | Q)
      echo "Exiting..."
      exit 0
      ;;

    *)
      echo "Unknown command: $cmd"
      sleep 1
      clear
      ;;
  esac
done
