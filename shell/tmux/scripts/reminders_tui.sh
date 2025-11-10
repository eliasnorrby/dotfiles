#!/usr/bin/env bash

# Simple TUI for managing reminders in a tmux popup
# Uses background checker loop that compares wall-clock time

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

# Function to check and fire due reminders
check_and_fire_reminders() {
  local now
  now=$(date +%s)

  if [[ ! -d "$REMINDERS_DIR" ]]; then
    return
  fi

  for file in "$REMINDERS_DIR"/reminder_*; do
    if [[ ! -f "$file" ]]; then
      continue
    fi

    local target
    target=$(sed -n '2p' "$file" 2>/dev/null)

    if [[ -n "$target" ]] && ((now >= target)); then
      local message
      message=$(head -n 1 "$file")
      send_notification "$message"
      rm -f "$file"
    fi
  done
}

# Background checker process
start_reminder_checker() {
  while true; do
    check_and_fire_reminders
    sleep 10
  done &
  CHECKER_PID=$!
}

# Kill checker on exit
cleanup() {
  if [[ -n "$CHECKER_PID" ]]; then
    kill "$CHECKER_PID" 2>/dev/null
  fi
}
trap cleanup EXIT INT TERM

# Function to parse duration/time into epoch timestamp
parse_time_to_epoch() {
  local input="$1"
  local now
  now=$(date +%s)

  # Check if it's an absolute time in HH:MM format
  if [[ "$input" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
    local hour="${BASH_REMATCH[1]}"
    local minute="${BASH_REMATCH[2]}"

    # Strip leading zeros to avoid octal interpretation
    hour=$((10#$hour))
    minute=$((10#$minute))

    # Validate hour and minute ranges
    if ((hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59)); then
      # Calculate target time today using perl
      local target
      target=$(perl -e "use Time::Local; my (\$sec,\$min,\$hour,\$mday,\$mon,\$year) = localtime(time); print timelocal(0, $minute, $hour, \$mday, \$mon, \$year);")

      # If target is in the past, schedule for tomorrow
      if ((target <= now)); then
        target=$((target + 86400))
      fi

      echo "$target"
      return 0
    else
      return 1
    fi
  fi

  # Otherwise, parse as relative duration
  if [[ "$input" =~ ^([0-9]+)([mhd])$ ]]; then
    local num="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2]}"

    local seconds=0
    case "$unit" in
      m) seconds=$((num * 60)) ;;
      h) seconds=$((num * 3600)) ;;
      d) seconds=$((num * 86400)) ;;
      *) return 1 ;;
    esac

    echo $((now + seconds))
    return 0
  else
    return 1
  fi
}

# Function to start a reminder
start_reminder() {
  local message="$1"
  local time_input="$2"

  local target_epoch
  if ! target_epoch=$(parse_time_to_epoch "$time_input"); then
    notify_error "Invalid time/duration: \"$time_input\""
    return 1
  fi

  # Create unique ID for this reminder
  local reminder_id
  reminder_id="reminder_$$_$(date +%s)_$RANDOM"
  local reminder_file="$REMINDERS_DIR/$reminder_id"

  # Store reminder: line 1 = message, line 2 = target epoch
  {
    echo "$message"
    echo "$target_epoch"
  } >"$reminder_file"

  # Inform user
  local target_time
  target_time=$(perl -e "use POSIX qw(strftime); print strftime('%H:%M', localtime($target_epoch))")
  terminal-notifier -title "Reminder Set" -message "I'll remind you to \"$message\" at $target_time." -sound default

  return 0
}

# Function to count active reminders
count_reminders() {
  local now
  now=$(date +%s)

  # Clean up expired reminders
  if [[ -d "$REMINDERS_DIR" ]]; then
    for file in "$REMINDERS_DIR"/reminder_*; do
      if [[ -f "$file" ]]; then
        local target
        target=$(sed -n '2p' "$file" 2>/dev/null)
        # Remove if target is in the past (already fired but file still exists somehow)
        if [[ -n "$target" ]] && ((target < now)); then
          rm -f "$file"
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
        local target_epoch
        target_epoch=$(sed -n '2p' "$file" 2>/dev/null)

        if [[ -n "$target_epoch" ]]; then
          local target_time
          target_time=$(perl -e "use POSIX qw(strftime); print strftime('%a %b %d %H:%M:%S %Y', localtime($target_epoch))")
          echo "$count. $message (at $target_time)"
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
    # Remove all reminder files
    if [[ -d "$REMINDERS_DIR" ]]; then
      rm -f "$REMINDERS_DIR"/reminder_*
    fi

    echo "All reminders cleared."
    sleep 1
  else
    echo "Cancelled."
    sleep 1
  fi
}

# Start the background checker
start_reminder_checker

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
      read -r time_input

      if [[ -z "$time_input" ]]; then
        echo "Cancelled"
        continue
      fi

      start_reminder "$message" "$time_input"
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
