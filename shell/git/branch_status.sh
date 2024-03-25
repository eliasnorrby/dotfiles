#!/usr/bin/env bash

# List all branches and their status relative to master

ORANGE=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr 0) # No Color

MASTER="origin/master"
STATUS_LENGTH=6

main() {
  local branches maxlength

  branches=$(list_branches)

  for branch in $branches; do
    if [[ ${#branch} -gt $maxlength ]]; then
      maxlength=${#branch}
    fi
  done

  printf "%-${maxlength}s │ %${STATUS_LENGTH}s │ %-${STATUS_LENGTH}s │ %s \n" "branch" "behind" "ahead" "remote"
  printf "%-${maxlength}s ┼ %-${STATUS_LENGTH}s ┼ %-${STATUS_LENGTH}s ┼ %$((maxlength + 5))s \n" | sed 's/ /─/g'

  for branch in $branches; do
    printf "${ORANGE}%-${maxlength}s${NC} │ " "$branch"
    printf "${RED}%${STATUS_LENGTH}s${NC} │ " "$(behind "$branch")"
    printf "${GREEN}%-${STATUS_LENGTH}s${NC} │ " "$(ahead "$branch")"
    printf "%s \n" "$(remote "$branch")"
  done
}

ahead() {
  local branch=$1
  git rev-list --left-right "${branch}"..."${MASTER}" | grep -c '^<'
}

behind() {
  local branch=$1
  git rev-list --left-right "${branch}"..."${MASTER}" | grep -c '^>'
}

remote() {
  local branch=$1
  git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{u}" 2>/dev/null
}

list_branches() {
  git branch --sort='-committerdate' --format '%(refname:short)'
}

main
