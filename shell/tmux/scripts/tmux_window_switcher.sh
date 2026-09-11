#!/usr/bin/env bash
# Window switcher: list windows with their ticket/description annotation and
# jump to the one picked via fzf.
#
# Opens scoped to the current session; ctrl-a widens the list to every window
# on the server, ctrl-s narrows it back. The toggle is an fzf reload that
# re-invokes this script with --list, so both views share one code path.
set -euo pipefail

# Absolute path to ourselves: the reload binding below runs us again, and $0
# is the symlink under $TMUX_HOME when tmux invokes the binding.
self=$(readlink -f "${BASH_SOURCE[0]}")

# Popup sessions (_popup_*) back the toggleable overlays; they are never jump
# targets.
session_filter='#{?#{m:_*,#{session_name}},0,1}'

# Fields separated by "::" so names/descriptions can contain spaces. Each row
# is emitted as "<session>:<index><TAB><display>": fzf hides the key with
# --with-nth but returns the whole line, so the caller parses one shape no
# matter which mode produced the row.
list() {
  local mode=$1 current windows
  current=$(tmux display-message -p '#{session_name}:#{window_index}')

  if [ "$mode" = all ]; then
    windows=$(tmux list-windows -a -f "$session_filter" \
      -F '#{session_name}::#{window_index}::#{window_name}::#{@issue}::#{@desc}')
  else
    windows=$(tmux list-windows \
      -F '#{session_name}::#{window_index}::#{window_name}::#{@issue}::#{@desc}')
  fi

  printf '%s\n' "$windows" | awk -F'::' -v cur="$current" -v mode="$mode" '
    {
      # Rejoin any trailing fields: a description containing "::" would
      # otherwise be truncated at the split.
      desc = $5
      for (i = 6; i <= NF; i++) desc = desc "::" $i

      key = $1 ":" $2
      # "*" means "you are here", in both modes.
      here = (key == cur ? "*" : "")
      issue = ($4 == "" ? "-" : $4)

      if (mode == "all")
        printf "%s\t%-10s%-3s%-2s %-14s %-12s %s\n", key, $1, $2, here, $3, issue, desc
      else
        printf "%s\t%-3s%-2s %-14s %-12s %s\n", key, $2, here, $3, issue, desc
    }
  '
}

header() {
  case $1 in
    all) printf 'all sessions · ^s: this session' ;;
    *) printf 'this session · ^a: all sessions' ;;
  esac
}

# Reload entry point for the fzf toggle bindings.
if [ "${1:-}" = --list ]; then
  list "${2:-session}"
  exit 0
fi

choice=$(list session | fzf \
  --reverse --delimiter=$'\t' --with-nth=2.. \
  --header="$(header session)" \
  --bind="ctrl-a:reload('$self' --list all)+change-header($(header all))" \
  --bind="ctrl-s:reload('$self' --list session)+change-header($(header session))") || exit 0

target=${choice%%$'\t'*}
# switch-client on a window target also moves the client when the window
# lives in another session.
[ -n "$target" ] && tmux switch-client -t "$target"
