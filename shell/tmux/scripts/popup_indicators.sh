#!/usr/bin/env bash

# Get the current session name
current_session="$(tmux display -p '#S')"

# If we're in a popup session, extract the original session name
if [[ "$current_session" =~ ^_popup_(.+)_(prompt|terminal|scratch)$ ]]; then
  # Extract base session name, stripping any suffix
  original_session="${BASH_REMATCH[1]}"
  current_session="$original_session"
elif [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  # Handle base popup without suffix (if any still exist)
  original_session="${BASH_REMATCH[1]}"
  current_session="$original_session"
fi

# Build the expected popup session names
terminal_popup="_popup_${current_session}_terminal"
prompt_popup="_popup_${current_session}_prompt"
scratch_popup="_popup_${current_session}_scratch"

# Check if popup sessions exist
base_active=""
prompt_active=""
scratch_active=""

if tmux has-session -t "$terminal_popup" 2>/dev/null; then
  base_active="#[fg=yellow]󰆍 #[fg=default]"
fi

if tmux has-session -t "$prompt_popup" 2>/dev/null; then
  prompt_active="#[fg=blue] #[fg=default]"
fi

if tmux has-session -t "$scratch_popup" 2>/dev/null; then
  scratch_active="#[fg=cyan] #[fg=default]"
fi

# Output the indicators (they'll appear side by side if both are active)
echo "${prompt_active} ${base_active} ${scratch_active}" | sed 's/^\s*//;s/\s*$//'
