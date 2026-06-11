#!/usr/bin/env bash
# Remove the worktree you're in and close its tmux window (which-cmd g>w>D).
#
# Inverse of tmux_start_work: run from inside a worktree (under
# <main>/.worktrees), it removes that worktree and kills the tmux window tied to
# it via the @worktree option. Refuses to touch the main worktree.
#
# Bound as an anchored, immediate which-cmd entry, so it runs inline in the
# pane's own shell — killing the window therefore terminates this shell. We do
# that last, and only after a clean removal, so a failed remove leaves the
# window (and your work) intact.
set -uo pipefail

# Shared helpers, installed on PATH by the git topic; located at run time.
# shellcheck disable=SC1090,SC1091
source "$(command -v worktree_lib.sh)" || {
  echo "worktree_lib.sh not found on PATH" >&2
  exit 1
}

is_in_git_repo || {
  echo "Not in a git repository" >&2
  exit 1
}

current=$(git rev-parse --show-toplevel)
main_root=$(main_worktree)

if [ "$current" = "$main_root" ]; then
  echo "Refusing to remove the main worktree ($current)" >&2
  exit 1
fi

# Find the window tied to this worktree before we delete it out from under us.
win=""
if [ -n "${TMUX:-}" ]; then
  win=$(tmux list-windows -F '#{window_index}::#{@worktree}' \
    | awk -F'::' -v p="$current" '$2 == p { print $1; exit }')
fi

# Operate from the main worktree so git's cwd isn't the directory being removed.
if ! git -C "$main_root" worktree remove "$current"; then
  echo "git worktree remove failed — leaving the window open" >&2
  exit 1
fi

# Done last: this kills the very shell the script is running in.
if [ -n "$win" ]; then
  tmux kill-window -t "$win"
fi
