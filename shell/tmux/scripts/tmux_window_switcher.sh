#!/usr/bin/env bash
# Window switcher: list every window in the current session with its
# ticket/description annotation and jump to the one picked via fzf.
set -euo pipefail

# Fields separated by "::" so names/descriptions can contain spaces.
windows=$(tmux list-windows -F '#{window_index}::#{?window_active,*,}::#{window_name}::#{@issue}::#{@desc}')

formatted=$(printf '%s\n' "$windows" | awk -F'::' '
  { printf "%-3s%-2s %-14s %-12s %s\n", $1, $2, $3, ($4 == "" ? "-" : $4), $5 }
')

choice=$(printf '%s\n' "$formatted" | fzf --reverse --no-sort --header='Switch window') || exit 0

index=$(printf '%s\n' "$choice" | awk '{print $1}')
[ -n "$index" ] && tmux select-window -t "$index"
