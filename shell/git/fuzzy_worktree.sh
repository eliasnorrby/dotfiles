#!/usr/bin/env bash
# Worktree switcher (tmux): pick a git worktree and jump to its window.
#
# Windows are tied to a worktree via the @worktree window option (its path).
# Selecting a worktree switches to its tagged window, or — if none exists —
# opens a new window cwd'd to the worktree and tags it. Meant to run in a tmux
# popup (see `bind W` in tmux.conf): every side effect goes through a tmux
# command, so it persists in the parent session after the popup closes.

# Shared helpers, installed on PATH by the git topic; located at run time.
# shellcheck disable=SC1090,SC1091
source "$(command -v worktree_lib.sh)"

GIT_LOG_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar)%Creset'

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
  go_to_worktree "$path" >/dev/null
}

main
