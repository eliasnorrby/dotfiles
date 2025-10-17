#!/usr/bin/env bash

# Get the current session name
current_session="$(tmux display -p '#S')"

# If we're in a popup session, extract the original session name
if [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  # Extract the base session name from the popup session name
  # Handle both _popup_<session> and _popup_<session>_prompt
  original_session="${BASH_REMATCH[1]}"
  # Remove _prompt suffix if present
  original_session="${original_session%_prompt}"
  current_session="$original_session"
fi

# Build the expected popup session names
base_popup="_popup_${current_session}"
prompt_popup="_popup_${current_session}_prompt"

# Check if popup sessions exist
base_active=""
prompt_active=""

if tmux has-session -t "$base_popup" 2>/dev/null; then
  base_active="#[fg=yellow]󰆍 #[fg=default]"
fi

if tmux has-session -t "$prompt_popup" 2>/dev/null; then
  prompt_active="#[fg=blue] #[fg=default]"
fi

# Output the indicators (they'll appear side by side if both are active)
echo "${prompt_active} ${base_active}"
