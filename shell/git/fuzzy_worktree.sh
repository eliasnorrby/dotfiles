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

# Remove a worktree (invoked from the fzf ctrl-d binding). On failure, keep the
# git error on screen until a key is pressed — fzf redraws over it otherwise.
delete_worktree() {
  printf 'deleting %s...\n' "$1"
  git worktree remove "$1" || {
    printf 'press any key to continue... '
    read -rsn1
  }
}

# Cancelling must exit 0: the popup binding uses display-popup -EE, which only
# auto-closes on success — a propagated fzf 130 leaves a dead popup behind.
main() {
  is_in_git_repo || return 0
  local main_root title choice path
  main_root=$(main_worktree)
  title=${main_root/#"$HOME"/\~}
  choice=$(worktree_rows "$main_root" | fzf --ansi --delimiter='\t' --with-nth=1 \
    --list-label " $title " --preview-window right:55% \
    --header 'ctrl-d: delete worktree' \
    --bind "ctrl-d:execute(\"$0\" --delete {2})+reload(\"$0\" --rows)" \
    --preview 'git -C {2} log --graph --color --abbrev-commit --pretty="'"$GIT_LOG_FORMAT"'" | head -200') || return 0
  [ -n "$choice" ] || return 0
  path=${choice##*$'\t'}
  go_to_worktree "$path" >/dev/null
}

# Internal subcommands let fzf bindings call back into this script, since bind
# commands run in a fresh shell where our functions don't exist.
case ${1-} in
  --rows) worktree_rows "$(main_worktree)" ;;
  --delete) delete_worktree "$2" ;;
  *) main ;;
esac
