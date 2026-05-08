#!/bin/sh

# Send the active window back to its "home" workspace based on windowrules in apps.conf

APPS_CONF="${XDG_CONFIG_HOME}/hypr/conf.d/apps.conf"

[ ! -f "$APPS_CONF" ] && exit 1

# Get class of active window
window_class() {
  hyprctl activewindow -j | jq -r '.class'
}

# Find workspace by testing each windowrule's class regex against the given class.
# Handles both the simple form ("windowrule = match:class PATTERN, workspace N")
# and the block form ("windowrule { match:class = PATTERN; workspace = N; }").
workspace_for_class() {
  class="$1"
  awk -v class="$class" '
    BEGIN { IGNORECASE = 1 }

    # Simple format: windowrule = match:class PATTERN, workspace N, ...
    /^[[:space:]]*windowrule[[:space:]]*=[[:space:]]*match:class[[:space:]]+/ {
      line = $0
      sub(/^[[:space:]]*windowrule[[:space:]]*=[[:space:]]*match:class[[:space:]]+/, "", line)
      pattern = line
      sub(/,.*/, "", pattern)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", pattern)
      if (match(line, /workspace[[:space:]]+/)) {
        after = substr(line, RSTART + RLENGTH)
        sub(/[[:space:]].*/, "", after)
        sub(/,.*/, "", after)
        if (pattern != "" && after != "" && class ~ pattern) {
          print after
          exit
        }
      }
      next
    }

    # Block format
    /^[[:space:]]*windowrule[[:space:]]*\{/ {
      in_block = 1
      block_pattern = ""
      block_ws = ""
      next
    }

    in_block && /^[[:space:]]*match:class[[:space:]]*=/ {
      p = $0
      sub(/^[[:space:]]*match:class[[:space:]]*=[[:space:]]*/, "", p)
      gsub(/[[:space:]]+$/, "", p)
      block_pattern = p
      next
    }

    in_block && /^[[:space:]]*workspace[[:space:]]*=/ {
      w = $0
      sub(/^[[:space:]]*workspace[[:space:]]*=[[:space:]]*/, "", w)
      gsub(/[[:space:]]+$/, "", w)
      block_ws = w
      next
    }

    in_block && /\}/ {
      if (block_pattern != "" && block_ws != "" && class ~ block_pattern) {
        print block_ws
        exit
      }
      in_block = 0
    }
  ' "$APPS_CONF"
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
