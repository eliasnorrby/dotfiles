#!/usr/bin/env bash

# Smart toggle for tasks popup (taskwarrior-tui)
# Wrapper around toggle_stateful_popup with tasks-specific settings

exec toggle_stateful_popup \
  --session=tasks \
  --title=Tasks \
  --color=green \
  taskwarrior-tui
