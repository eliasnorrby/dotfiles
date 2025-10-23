#!/usr/bin/env bash

# Smart toggle for scratch popup (nvim)
# Wrapper around toggle_stateful_popup with scratch-specific settings

exec toggle_stateful_popup \
  --session=scratch \
  --title=Scratch \
  --color=cyan \
  -d '#{pane_current_path}' \
  nvim
