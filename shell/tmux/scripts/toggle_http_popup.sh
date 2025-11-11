#!/usr/bin/env bash

# Smart toggle for http popup
# Wrapper around toggle_stateful_popup with http-specific settings

exec toggle_stateful_popup \
  --session=http \
  --title=HTTP \
  --color=magenta \
  -d '#{pane_current_path}' \
  -w 100% \
  -h 98% \
  zsh
