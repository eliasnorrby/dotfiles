#!/usr/bin/env bash

GIT_LOG_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar)%Creset'

is_in_git_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

fzf_worktree_select() {
  git worktree list \
    | fzf --ansi --list-label ' Worktrees ' --preview-window right:70% \
      --preview 'git -C $(cut -d" " -f1 <<< {}) log --graph --color --abbrev-commit --pretty="'"$GIT_LOG_FORMAT"'" | head -200' \
    | cut -d' ' -f1
}

main() {
  is_in_git_repo || return
  local worktree
  worktree=$(fzf_worktree_select)
  if [[ -z "$worktree" ]]; then
    return
  fi
  cd "$worktree" || return
}

main
