#!/bin/sh

# Usage: focus_or_run <class> [program] [args...]
# Focuses window with matching class/app_id, or runs program if not found.

CLASS="$1"
PROGRAM="${2:-$1}"
shift 2 2>/dev/null

# Check if window exists (search both class and initialClass)
if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\" or .initialClass == \"$CLASS\")" > /dev/null 2>&1; then
  hyprctl dispatch focuswindow "class:$CLASS"
else
  if command -v "$PROGRAM" > /dev/null 2>&1; then
    exec "$PROGRAM" "$@"
  else
    echo "Could not focus or run: $PROGRAM"
    exit 1
  fi
fi
