#!/usr/bin/env bash

# Persistent editor wrapper for Claude Code
# Allows toggling the popup on/off without terminating the editing session

TMPFILE="$1"
DONEFILE="/tmp/claude_editor_$$.done"

# Cleanup on exit
cleanup() {
  rm -f "$DONEFILE"
}
trap cleanup EXIT

# Claude runs as a terminal job of some nvim when $NVIM is set (sidekick and
# plain :terminal both export the server address), and Ctrl+G was pressed in
# that nvim's current window. Ask the very nvim that owns Claude rather than
# keying the tmux pane, which can't tell a sidekick float from claude_vim's
# fullscreen buffer and starts a fresh sidekick Claude in the latter.
# Headless and off the tty: given a terminal, the client draws a UI of its
# own and the reply drowns in escape codes.
nvim_remote() {
  nvim --headless --server "$NVIM" --remote-expr "$1" </dev/null 2>/dev/null
}

# Only the sidekick float needs hiding: it would sit blank under the prompt
# popup. A Claude filling a regular window is left alone.
claude_in_float() {
  [[ -n "${NVIM:-}" ]] && [[ "$(nvim_remote "nvim_win_get_config(0).relative != ''")" == 1 ]]
}

# :Claude toggles the float (defined in the sidekick plugin spec)
toggle_claude_float() {
  nvim_remote 'execute("Claude")' >/dev/null
}

# If not in tmux, just use regular nvim
if [[ -z "$TMUX" ]]; then
  nvim '+set nonumber norelativenumber' '+normal G$' "$TMPFILE"
  exit 0
fi

current_pane="$(tmux display-message -p '#{pane_id}')"

hid_claude=false
if claude_in_float; then
  toggle_claude_float
  hid_claude=true
fi

# Show popup attached to the session
# When popup closes, session stays alive in background
# VimLeave autocommand touches the done file when nvim exits
# Using --session=prompt to create a dedicated prompt popup session
display_stateful_popup --title=Prompt --color=blue --session=prompt \
  "nvim" \
  "+set nonumber norelativenumber" \
  "+autocmd VimLeave * call writefile([], '$DONEFILE')" \
  '+normal G$' \
  "$TMPFILE"

# Wait for the done file to be created (Ctrl+Q pressed)
while [[ ! -f "$DONEFILE" ]]; do
  sleep 0.5
done

# If we hid the Claude float, restore it now
if [[ "$hid_claude" == true ]]; then
  # Check if the original pane still exists
  if tmux list-panes -a -F '#{pane_id}' | grep -q "^${current_pane}$"; then
    # Switch to the window containing the pane, then select the pane
    pane_window="$(tmux display-message -p -t "$current_pane" '#{window_id}')"
    tmux select-window -t "$pane_window"
    tmux select-pane -t "$current_pane"
  fi
  # A no-op if that nvim has since exited
  toggle_claude_float
fi

cleanup
