#!/usr/bin/env bash

# Smart toggle for tasks popup (taskwarrior-tui)
# Wrapper around toggle_stateful_popup with tasks-specific settings
# Global popup shared across all tmux sessions

exec toggle_stateful_popup \
  --session=tasks \
  --title=Tasks \
  --color=green \
  --global \
  taskwarrior-tui
