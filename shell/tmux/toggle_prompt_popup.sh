#!/usr/bin/env bash

# Smart toggle for prompt popup
# - If prompt session exists and is hidden: show it
# - If prompt session exists and is in foreground: hide it
# - If prompt session doesn't exist: propagate Ctrl-p to underlying app (neovim)

# Get current session info
current_session="$(tmux display -p '#S')"

# Determine the base session name (handle if we're already in a popup)
if [[ "$current_session" =~ ^_popup_(.+)_(prompt|terminal|scratch)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
elif [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
else
  base_session="$current_session"
fi

# Build the prompt popup session name
prompt_popup="_popup_${base_session}_prompt"

# Check if prompt popup session exists
if tmux has-session -t "$prompt_popup" 2>/dev/null; then
  # Session exists - check if we're currently in it (foreground)
  if [[ "$current_session" == "$prompt_popup" ]]; then
    # We're in the prompt popup - detach to hide it
    tmux detach-client
  else
    # We're not in the prompt popup - show it
    display_stateful_popup --title=Prompt --color=blue --session=prompt --attach-only
  fi
else
  # Session doesn't exist - propagate Ctrl-p to the underlying application
  # This will trigger neovim's Claude popup if neovim is in the foreground
  tmux send-keys C-p
fi
