#!/usr/bin/env bash

# Simple TUI for managing reminders in a tmux popup
# Runs in a loop, allowing multiple timers to run concurrently

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

# Function to parse duration into seconds
parse_duration() {
  local duration="$1"

  # Extract number and unit
  if [[ "$duration" =~ ^([0-9]+)([smhd]?)$ ]]; then
    local num="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2]}"

    case "$unit" in
      s | "") echo "$num" ;;         # seconds (default)
      m) echo $((num * 60)) ;;       # minutes
      h) echo $((num * 3600)) ;;     # hours
      d) echo $((num * 86400)) ;;    # days
      *) return 1 ;;
    esac
  else
    return 1
  fi
}

# Function to start a reminder in the background
start_reminder() {
  local message="$1"
  local duration="$2"

  local seconds
  if ! seconds=$(parse_duration "$duration"); then
    notify_error "Invalid duration: \"$duration\""
    return 1
  fi

  # Create unique ID for this reminder
  local reminder_id="reminder_$$_$(date +%s)_$RANDOM"
  local reminder_file="$REMINDERS_DIR/$reminder_id"

  # Store reminder info
  echo "$message" >"$reminder_file"

  # Start background process
  ( 
    sleep "$seconds"
    if [[ -f "$reminder_file" ]]; then
      send_notification "$message"
      rm -f "$reminder_file"
    fi
  ) &

  # Inform user
  terminal-notifier -title "Reminder Set" -message "I'll remind you to \"$message\" in $duration." -sound default

  return 0
}

# Function to count active reminders
count_reminders() {
  find "$REMINDERS_DIR" -type f -name 'reminder_*' 2>/dev/null | wc -l | tr -d ' '
}

# Function to list active reminders
list_reminders() {
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
        message=$(cat "$file")
        echo "$count. $message"
      fi
    done
  fi
  echo ""
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
echo "  q       - Quit"
echo ""

while true; do
  list_reminders

  echo -n "Command (Enter/l/q): "
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

      echo -n "Remind me in (e.g., 10m, 5s, 1h): "
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
