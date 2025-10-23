#!/usr/bin/env bash

# Smart toggle for terminal popup
# Wrapper around toggle_stateful_popup with terminal-specific settings

exec toggle_stateful_popup \
  --session=terminal \
  --title=Terminal \
  --color=yellow \
  -d '#{pane_current_path}'
