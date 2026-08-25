#!/usr/bin/env bash
# Annotate the current tmux window from an issue/PR reference.
#
# Resolution is delegated to issue_resolve, which tries an explicit argument,
# then the clipboard, then the git branch -- here the active pane's, so
# targeting another window annotates it from its own checkout. This script
# owns only the tmux side: it sets the window name (@issue) plus the @desc
# option used by the pane border and window switcher.
#
# Pure annotation only: no branch/worktree side effects, so it is safe to run
# whether starting new work or resuming an existing checkout.

set -uo pipefail

notify() {
  tmux display-message "$*"
}

# Print the working directory to read a branch from: the target window's pane
# path when -t is in play, else the current directory (the `I` binding cd's
# there before invoking us).
branch_dir() {
  local target=$1 dir
  if [ -n "$target" ]; then
    dir=$(tmux display-message -p -t "$target" '#{pane_current_path}' 2>/dev/null)
    [ -n "$dir" ] && printf '%s' "$dir" && return 0
  fi
  printf '%s' "$PWD"
}

# Usage: tmux_set_issue [-t <window>] [<reference>]
main() {
  local target="" arg="" result issue desc rc
  local tgt=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -t)
        target=$2
        shift 2
        ;;
      *)
        arg=$1
        shift
        ;;
    esac
  done

  # issue_resolve keeps stdout clean on success and reports failures on
  # stderr, so merging the streams yields either the result or the message.
  result=$(issue_resolve --branch-from "$(branch_dir "$target")" ${arg:+"$arg"} 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    notify "$result"
    exit 1
  fi

  issue=${result%%$'\t'*}
  desc=${result#*$'\t'}

  [ -n "$target" ] && tgt=(-t "$target")
  tmux set -w "${tgt[@]}" @issue "$issue"
  tmux set -w "${tgt[@]}" @desc "$desc"
  tmux rename-window "${tgt[@]}" "$issue"
  notify "$issue — $desc"
}

main "$@"
