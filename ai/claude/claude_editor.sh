#!/usr/bin/env bash

if [[ -n "$TMUX" ]]; then
  tmux display-popup -E -b rounded -T 'Prompt' -S 'fg=blue' "nvim" "+set nonumber norelativenumber" "$@"
else
  nvim "$@"
fi
