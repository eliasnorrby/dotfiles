#!/usr/bin/env bash
if [[ -n "$TMUX" ]]; then
  tmux display-popup -E -b rounded -T 'Prompt' "nvim" "$@"
else
  nvim "$@"
fi
