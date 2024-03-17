#!/usr/bin/env bash

TMUX_STATUS_ON_VALUE=2

current_status=$(tmux show-options status | cut -d ' ' -f 2)

if [ "$current_status" == "$TMUX_STATUS_ON_VALUE" ]; then
  tmux set-option status off
else
  tmux set-option status $TMUX_STATUS_ON_VALUE
fi
