#!/usr/bin/env bash

GIT_LOG_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar)%Creset'

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf_branch_select() {
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --graph --color --abbrev-commit --branches --pretty="'"$GIT_LOG_FORMAT"'" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

main() {
  is_in_git_repo || return
  local branch
  branch=$(fzf_branch_select)
  if [[ -z "$branch" ]]; then
    return
  fi
  git checkout "$branch"
}

main
