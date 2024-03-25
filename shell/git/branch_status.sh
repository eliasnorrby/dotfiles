#!/usr/bin/env bash

# List all branches and their status relative to master

ORANGE=$(tput setaf 3)
PURPLE=$(tput setaf 5)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr 0) # No Color

MASTER="origin/master"
STATUS_LENGTH=6
REMOTE_LENGTH=1
PR_LENGTH=14

main() {
  local mode=$1 branches maxlength prs

  branches=$(list_branches)

  prs=$(list_prs)

  for branch in $branches; do
    if [[ ${#branch} -gt $maxlength ]]; then
      maxlength=${#branch}
    fi
  done

  printf "%${REMOTE_LENGTH}s %-${maxlength}s │ %${STATUS_LENGTH}s │ %-${STATUS_LENGTH}s │ %s \n" "" "branch" "behind" "ahead" "pr"
  printf "%${REMOTE_LENGTH}s %-${maxlength}s ┼ %-${STATUS_LENGTH}s ┼ %-${STATUS_LENGTH}s ┼ %${PR_LENGTH}s \n" | sed 's/ /─/g'

  for branch in $branches; do
    printf "%-${REMOTE_LENGTH}s " "$(remote "$branch")"
    printf "${ORANGE}%-${maxlength}s${NC} │ " "$branch"
    printf "${RED}%${STATUS_LENGTH}s${NC} │ " "$(behind "$branch")"
    printf "${GREEN}%-${STATUS_LENGTH}s${NC} │ " "$(ahead "$branch")"
    printf "%${PR_LENGTH}s \n" "$(pull_request "$prs" "$branch" "$mode")"
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
  local branch=$1 remote
  remote=$(git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{u}" 2>/dev/null)
  if [[ -n "$remote" ]]; then
    echo "${GREEN}•${NC}"
  fi
}

list_branches() {
  git branch --sort='-committerdate' --format '%(refname:short)' | grep -v 'master'
}

list_prs() {
  gh pr list --state all --json number,state,headRefName 2>/dev/null
}

single_pr() {
  local branch=$1
  gh pr view "$branch" --json number,state 2>/dev/null
}

pull_request() {
  local prs=$1 branch=$2 mode=$3 number state pr remote
  pr=$(echo "$prs" | jq -r ".[] | select(.headRefName == \"$branch\")")
  if [[ -z "$pr" ]]; then
    if [[ "$mode" != "full" ]]; then
      return
    fi
    remote=$(remote "$branch")
    if [[ -z "$remote" ]]; then
      return
    fi
    pr=$(single_pr "$branch")
    if [[ -z "$pr" ]]; then
      return
    fi
  fi
  number=$(echo "$pr" | jq -r '.number')
  state=$(echo "$pr" | jq -r '.state')
  printf "#%s (%s)" "$number" "$(pr_state "$state")"
}

pr_state() {
  local state=$1
  case $state in
    "OPEN") echo "${GREEN}$state${NC}" ;;
    "CLOSED") echo "${RED}$state${NC}" ;;
    "MERGED") echo "${PURPLE}$state${NC}" ;;
    *) echo "${ORANGE}$state${NC}" ;;
  esac
}

main "$@"
