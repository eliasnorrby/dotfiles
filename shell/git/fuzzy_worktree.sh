#!/usr/bin/env bash
# Worktree switcher (tmux): pick a git worktree and jump to its window.
#
# Windows are tied to a worktree via the @worktree window option (its path).
# Selecting a worktree switches to its tagged window, or — if none exists —
# opens a new window cwd'd to the worktree and tags it. Meant to run in a tmux
# popup (see `bind W` in tmux.conf): every side effect goes through a tmux
# command, so it persists in the parent session after the popup closes.

GIT_LOG_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar)%Creset'

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

# Emit one row per worktree as "<display><TAB><path>". The display column shows
# an indicator (● tied window / ○ none), the short worktree name, the branch and,
# when tied, the window index plus its @issue annotation.
worktree_rows() {
  local main=$1 windows
  windows=$(tmux list-windows -F '#{@worktree}::#{window_index}::#{@issue}' 2>/dev/null)

  git worktree list | while IFS= read -r line; do
    local path branch name match indicator detail
    path=${line%% *}
    branch=$(sed -n 's/.*\[\(.*\)\].*/\1/p' <<<"$line")
    name=$(worktree_label "$path" "$main")
    match=$(awk -F'::' -v p="$path" '$1 == p { print $2 "\t" $3; exit }' <<<"$windows")
    if [ -n "$match" ]; then
      indicator="●"
      detail="win ${match%%$'\t'*}"
      local issue=${match#*$'\t'}
      [ -n "$issue" ] && detail="$detail  $issue"
    else
      indicator="○"
      detail="—"
    fi
    printf '%s  %-22s %-34s %s\t%s\n' "$indicator" "$name" "$branch" "$detail" "$path"
  done
}

# Switch to the window tied to a worktree, creating and tagging one if needed.
go_to_worktree() {
  local path=$1 index win
  index=$(tmux list-windows -F '#{window_index}::#{@worktree}' \
    | awk -F'::' -v p="$path" '$2 == p { print $1; exit }')
  if [ -n "$index" ]; then
    tmux select-window -t "$index"
  else
    win=$(tmux new-window -c "$path" -P -F '#{window_id}')
    tmux set -w -t "$win" @worktree "$path"
    tmux rename-window -t "$win" "$(basename "$path")"
  fi
}

main() {
  is_in_git_repo || return
  local main_root title choice path
  main_root=$(main_worktree)
  title=${main_root/#"$HOME"/\~}
  choice=$(worktree_rows "$main_root" | fzf --ansi --delimiter='\t' --with-nth=1 \
    --list-label " $title " --preview-window right:55% \
    --preview 'git -C {2} log --graph --color --abbrev-commit --pretty="'"$GIT_LOG_FORMAT"'" | head -200') || return
  [ -n "$choice" ] || return
  path=${choice##*$'\t'}
  go_to_worktree "$path"
}

main
