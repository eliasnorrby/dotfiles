#!/bin/sh

# Usage: launch_on_workspace <workspace> <class> <program> [args...]
# Switches to workspace and focuses window with class, or launches program if not found.

if [ $# -lt 3 ]; then
  echo "Usage: $0 WORKSPACE CLASS PROGRAM [args...]"
  exit 1
fi

WORKSPACE="$1"
CLASS="$2"
PROGRAM="$3"
shift 3

# Switch to workspace
hyprctl dispatch workspace "$WORKSPACE"

# Check if window with class exists on this workspace
if hyprctl clients -j | jq -e ".[] | select(.workspace.id == $WORKSPACE and (.class == \"$CLASS\" or .initialClass == \"$CLASS\"))" >/dev/null  2>&1; then
  hyprctl dispatch focuswindow "class:$CLASS"
else
  if command -v "$PROGRAM" >/dev/null  2>&1; then
    exec "$PROGRAM" "$@"
  else
    echo "Could not launch: $PROGRAM"
    exit 1
  fi
fi
