#!/usr/bin/env bash

# Smart toggle for reminders popup
# Wrapper around toggle_stateful_popup with reminders-specific settings
# Global popup shared across all tmux sessions

exec toggle_stateful_popup \
  --session=reminders \
  --title=Reminders \
  --color=magenta \
  --global \
  -w 60% \
  -h 70% \
  "$TMUX_HOME/scripts/reminders_tui.sh"
