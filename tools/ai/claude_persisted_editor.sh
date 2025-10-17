#!/usr/bin/env bash

# Persistent editor wrapper for Claude Code
# Allows toggling the popup on/off without terminating the editing session
# Use Ctrl+Q in vim to signal "I'm done editing"

TMPFILE="$1"
DONEFILE="/tmp/claude_editor_$$.done"
CLAUDE_HIDDEN_FLAG="/tmp/claude_popup_hidden_by_editor_$$.flag"

# Cleanup on exit
cleanup() {
  rm -f "$DONEFILE"
  rm -f "$CLAUDE_HIDDEN_FLAG"
}
trap cleanup EXIT

# If not in tmux, just use regular nvim
if [[ -z "$TMUX" ]]; then
  nvim "$TMPFILE"
  exit 0
fi

# Check if we're in a neovim pane by looking at the pane's process
current_pane="$(tmux display-message -p '#{pane_id}')"
pane_process="$(tmux display-message -p -t "$current_pane" '#{pane_current_command}')"

# If we're in neovim, hide the Claude popup before opening the editor
if [[ "$pane_process" =~ nvim ]]; then
  # Send C-p to hide the Claude popup
  tmux send-keys -t "$current_pane" C-p
  # Mark that we hid it so we can restore later
  touch "$CLAUDE_HIDDEN_FLAG"
fi

# Show popup attached to the session
# When popup closes, session stays alive in background
# VimLeave autocommand touches the done file when nvim exits
# Using --session=prompt to create a dedicated prompt popup session
tmux display-popup -E -b rounded -T 'Prompt' -S 'fg=blue' \
  tmux_popup --session=prompt "nvim" \
    "+set nonumber norelativenumber" \
    "+autocmd VimLeave * call writefile([], '$DONEFILE')" \
    "$TMPFILE"

# Wait for the done file to be created (Ctrl+Q pressed)
while [[ ! -f "$DONEFILE" ]]; do
  sleep 0.5
done

# If we hid the Claude popup, restore it now
if [[ -f "$CLAUDE_HIDDEN_FLAG" ]]; then
  # Check if the pane is still running neovim
  pane_process="$(tmux display-message -p -t "$current_pane" '#{pane_current_command}')"
  if [[ "$pane_process" =~ nvim ]]; then
    # Restore the Claude popup by sending C-p
    tmux send-keys -t "$current_pane" C-p
  fi
fi

cleanup
