#!/usr/bin/env bash

# Persistent editor wrapper for Claude Code
# Allows toggling the popup on/off without terminating the editing session

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
display_stateful_popup --title=Prompt --color=blue --session=prompt \
  "nvim" \
  "+set nonumber norelativenumber" \
  "+autocmd VimLeave * call writefile([], '$DONEFILE')" \
  "$TMPFILE"

# Wait for the done file to be created (Ctrl+Q pressed)
while [[ ! -f "$DONEFILE" ]]; do
  sleep 0.5
done

# If we hid the Claude popup, restore it now
if [[ -f "$CLAUDE_HIDDEN_FLAG" ]]; then
  # Check if the original pane still exists and is running neovim
  if tmux list-panes -a -F '#{pane_id}' | grep -q "^${current_pane}$"; then
    # Switch to the window containing the pane, then select the pane
    pane_window="$(tmux display-message -p -t "$current_pane" '#{window_id}')"
    tmux select-window -t "$pane_window"
    tmux select-pane -t "$current_pane"
    pane_process="$(tmux display-message -p -t "$current_pane" '#{pane_current_command}')"
    if [[ "$pane_process" =~ nvim ]]; then
      # Restore the Claude popup by sending C-p
      tmux send-keys -t "$current_pane" C-p
    fi
  fi
fi

cleanup
