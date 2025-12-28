#!/bin/sh

# Usage: focus_or_run <class> [program] [args...]
# or:    focus_or_run <name.desktop>
#
# Mode 1: Focuses window with matching class, or runs program if not found.
# Mode 2: Parses .desktop file for class and exec command.
#
# Special workspace handling: If window is in a special workspace, toggles it.

APPLICATIONS_DIR="$HOME/.local/share/applications"

# Check if first argument is a .desktop file
if echo "$1" | grep -q '\.desktop$'; then
  DESKTOP_FILE="$APPLICATIONS_DIR/$1"

  if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Desktop file not found: $DESKTOP_FILE"
    exit 1
  fi

  # Extract StartupWMClass, fall back to filename without .desktop
  CLASS=$(grep -m1 '^StartupWMClass=' "$DESKTOP_FILE" | cut -d= -f2-)
  if [ -z "$CLASS" ]; then
    CLASS=$(basename "$1" .desktop)
  fi

  # Extract Exec command and strip field codes (%u, %U, %f, %F, etc.)
  EXEC_CMD=$(grep -m1 '^Exec=' "$DESKTOP_FILE" | cut -d= -f2- | sed 's/ %[uUfFdDnNickvm]//g')

  if [ -z "$EXEC_CMD" ]; then
    echo "No Exec command found in: $DESKTOP_FILE"
    exit 1
  fi
else
  # Original mode: class and program as arguments
  CLASS="$1"
  PROGRAM="${2:-$1}"
  shift 2 2>/dev/null
  EXEC_CMD="$PROGRAM $*"
fi

# Check if window exists and get its workspace
WINDOW_INFO=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\" or .initialClass == \"$CLASS\") | .workspace.name" | head -1)

if [ -z "$WINDOW_INFO" ]; then
  # Window doesn't exist - launch it
  eval "$EXEC_CMD"
  exit
fi

# Check if this window is currently focused
ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r '.class')

if [ "$ACTIVE_CLASS" = "$CLASS" ] && echo "$WINDOW_INFO" | grep -q '^special:'; then
  # Focused and in special workspace - hide it
  SPECIAL_NAME=$(echo "$WINDOW_INFO" | sed 's/^special://')
  hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
else
  # Not focused - just focus (works for both regular and special workspaces)
  hyprctl dispatch focuswindow "class:$CLASS"
fi
