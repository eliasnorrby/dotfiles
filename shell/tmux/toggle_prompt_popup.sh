#!/usr/bin/env bash

# Smart toggle for prompt popup
# Wrapper around toggle_stateful_popup with prompt-specific settings
# If session doesn't exist, propagates Ctrl-p to underlying app (neovim)

exec toggle_stateful_popup \
  --session=prompt \
  --title=Prompt \
  --color=blue \
  --fallback 'tmux send-keys C-p'
