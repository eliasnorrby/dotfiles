#!/usr/bin/env bash

export GH_FORCE_TTY='50%'

main() {
  if ! is_in_git_repo; then
    echo "Not in a git repo"
    return 1
  fi

  export list_cmd='git branch --format "%(refname:short)" | grep -vE "^local"'

  list_branches | fzf --preview 'gh pr view {}' \
    --bind "ctrl-d:execute-silent(git branch -D {})+reload($list_cmd)"
}

list_branches() {
  git branch --format '%(refname:short)' | grep -vE '^local'
}

export -f list_branches

is_in_git_repo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}

main
