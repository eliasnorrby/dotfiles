#!/usr/bin/env bash

# Persistent editor wrapper for Claude Code
# Allows toggling the popup on/off without terminating the editing session
# Use Ctrl+Q in vim to signal "I'm done editing"

TMPFILE="$1"
DONEFILE="/tmp/claude_editor_test.done"

# Cleanup on exit
cleanup() {
  rm -f "$DONEFILE"
}
trap cleanup EXIT

# If not in tmux, just use regular nvim
if [[ -z "$TMUX" ]]; then
  nvim "$TMPFILE"
  exit 0
fi

# Show popup attached to the session
# When popup closes, session stays alive in background
# VimLeave autocommand touches the done file when nvim exits
tmux display-popup -E -b rounded -T 'Prompt' -S 'fg=yellow' \
  tmux_popup "nvim" \
    "+set nonumber norelativenumber" \
    "+autocmd VimLeave * call writefile([], '$DONEFILE')" \
    "$TMPFILE"

# Wait for the done file to be created (Ctrl+Q pressed)
while [[ ! -f "$DONEFILE" ]]; do
  sleep 0.5
done

cleanup
