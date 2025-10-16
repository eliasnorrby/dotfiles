#!/usr/bin/env bash

bell() {
  # If running inside tmux, write bell directly to the pane's TTY
  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    # Get the TTY of the tmux pane
    pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
    if [ -n "$pane_tty" ] && [ -w "$pane_tty" ]; then
      # Write bell character directly to the pane's TTY
      printf '\a' > "$pane_tty" 2>/dev/null || printf '\a'
    else
      printf '\a'
    fi
  else
    # Not in tmux, just print bell normally
    printf '\a'
  fi
}

bell

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "Claude" -message "Claude has finished processing your request."
fi

if command -v afplay >/dev/null 2>&1; then
  afplay -v 3 /System/Library/Sounds/Funk.aiff
fi
