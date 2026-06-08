#!/usr/bin/env bash
# Shared git-worktree helpers. Pure definitions — nothing runs on source, so it
# is safe to source from anywhere (no sourced-vs-executed guard needed). Sourced
# by fuzzy_worktree.sh (the prefix W picker) and tmux_start_work.sh (prefix N).

is_in_git_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

# The path of the main worktree (git lists it first). Other worktrees live, by
# convention, under <main>/.worktrees.
main_worktree() {
  git worktree list | awk '{ print $1; exit }'
}

# Short display name for a worktree path: the main worktree shows its basename,
# worktrees under <main>/.worktrees show their name relative to that dir, and
# anything else falls back to a ~-abbreviated path.
worktree_label() {
  local path=$1 main=$2
  if [ "$path" = "$main" ]; then
    basename "$path"
  elif [[ "$path" == "$main/.worktrees/"* ]]; then
    printf '%s' "${path#"$main"/.worktrees/}"
  else
    printf '%s' "${path/#"$HOME"/\~}"
  fi
}

# Switch to the window tied to a worktree, creating and tagging one if needed.
# Echoes the window (index or id) it selected or created, for callers to target.
go_to_worktree() {
  local path=$1 index win
  index=$(tmux list-windows -F '#{window_index}::#{@worktree}' \
    | awk -F'::' -v p="$path" '$2 == p { print $1; exit }')
  if [ -n "$index" ]; then
    tmux select-window -t "$index"
    printf '%s\n' "$index"
  else
    win=$(tmux new-window -c "$path" -P -F '#{window_id}')
    tmux set -w -t "$win" @worktree "$path"
    tmux rename-window -t "$win" "$(basename "$path")"
    printf '%s\n' "$win"
  fi
}
