#!/bin/sh

# Send the active window back to its "home" workspace based on windowrules in apps.conf

APPS_CONF="${XDG_CONFIG_HOME}/hypr/conf.d/apps.conf"

[ ! -f "$APPS_CONF" ] && exit 1

# Get class of active window
window_class() {
  hyprctl activewindow -j | jq -r '.class'
}

# Find workspace for class from windowrules
# Handles both simple and block formats
workspace_for_class() {
  class="$1"
  workspace=""

  # Try simple format first: windowrule = match:class CLASS, workspace N
  workspace=$(grep -i "match:class.*$class" "$APPS_CONF" | grep -oP 'workspace \K[^\s,]+' | head -1)

  # If not found, try block format
  if [ -z "$workspace" ]; then
    workspace=$(awk -v class="$class" '
      BEGIN { IGNORECASE=1 }
      /windowrule \{/,/\}/ {
        if ($0 ~ "match:class[[:space:]]*=[[:space:]]*" class) found=1
        if (found && /workspace[[:space:]]*=/) {
          gsub(/.*workspace[[:space:]]*=[[:space:]]*/, "")
          gsub(/[[:space:]].*/, "")
          print
          exit
        }
        if (/\}/) found=0
      }
    ' "$APPS_CONF")
  fi

  echo "$workspace"
}

send_to_workspace() {
  hyprctl dispatch movetoworkspace "$1"
}

notify() {
  notify-send -u low -t 2300 "$@"
}

class=$(window_class)
[ -z "$class" ] && notify "Could not determine class of current window" && exit 1

workspace=$(workspace_for_class "$class")
[ -z "$workspace" ] && notify "No rule found for window with class '$class'" && exit 1

send_to_workspace "$workspace"
