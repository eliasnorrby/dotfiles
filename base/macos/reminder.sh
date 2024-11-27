#!/usr/bin/env bash

# =====================================================================
# Simple Reminder Script for macOS
# =====================================================================
# This script:
#   1. Prompts the user for a reminder message.
#   2. Prompts the user for a duration (e.g., 10m, 5s, 1h).
#   3. Sleeps for the specified duration.
#   4. Displays a persistent notification using terminal-notifier.
# =====================================================================

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

# Prompt for the reminder message
echo -n "Remind me to: "
read -r MESSAGE

# Exit if the reminder message is empty
if [ -z "$MESSAGE" ]; then
  exit 0
fi

# Prompt for the duration
echo -n "Remind me in (e.g., 10m, 5s, 1h): "
read -r DURATION

# Exit if the duration is empty
if [ -z "$DURATION" ]; then
  exit 0
fi

# Start the sleep and notification in the background
( 
  # Attempt to sleep for the specified duration
  sleep "$DURATION"
  # Check if sleep was successful
  if [ $? -eq 0 ]; then
    # Send the reminder notification
    send_notification "$MESSAGE"
  else
    # If sleep failed, send an error notification
    notify_error "Invalid duration: \"$DURATION\""
  fi
) &

# Disown the background process to allow the script to exit independently
disown

# Optional: Inform the user that the reminder has been set
terminal-notifier -title "Reminder Set" -message "I'll remind you to \"$MESSAGE\" in $DURATION." -sound default

exit 0
