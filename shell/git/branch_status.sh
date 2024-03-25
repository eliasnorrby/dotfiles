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
PR_NUMBER_LENGTH=5
PR_STATE_LENGTH=6
CHECKS_LENGTH=10

main() {
  local mode=$1 branches maxlength prs

  branches=$(list_branches)

  prs=$(list_prs)

  for branch in $branches; do
    if [[ ${#branch} -gt $maxlength ]]; then
      maxlength=${#branch}
    fi
  done

  printf "%${REMOTE_LENGTH}s %-${maxlength}s │ %${STATUS_LENGTH}s │ %-${STATUS_LENGTH}s │ %-${PR_NUMBER_LENGTH}s │ %-${PR_STATE_LENGTH}s │ %s \n" "" "branch" "behind" "ahead" "pr" "state" "checks"
  printf "%${REMOTE_LENGTH}s %-${maxlength}s ┼ %-${STATUS_LENGTH}s ┼ %-${STATUS_LENGTH}s ┼ %${PR_NUMBER_LENGTH}s ┼ %${PR_STATE_LENGTH}s ┼ %${CHECKS_LENGTH}s \n" | sed 's/ /─/g'

  for branch in $branches; do
    printf "%-${REMOTE_LENGTH}s " "$(remote "$branch")"
    printf "${ORANGE}%-${maxlength}s${NC} │ " "$branch"
    printf "${RED}%${STATUS_LENGTH}s${NC} │ " "$(behind "$branch")"
    printf "${GREEN}%-${STATUS_LENGTH}s${NC} │ " "$(ahead "$branch")"
    pull_request "$prs" "$branch" "$mode"
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
  gh pr list --state all --json number,state,headRefName,statusCheckRollup 2>/dev/null
}

single_pr() {
  local branch=$1
  gh pr view "$branch" --json number,state,statusCheckRollup 2>/dev/null
}

pull_request() {
  local prs=$1 branch=$2 mode=$3 number state pr remote checks
  pr=$(echo "$prs" | jq -r ".[] | select(.headRefName == \"$branch\")")
  if [[ -z "$pr" ]]; then
    if [[ "$mode" != "full" ]]; then
      _empty_pr_line
      return
    fi
    remote=$(remote "$branch")
    if [[ -z "$remote" ]]; then
      _empty_pr_line
      return
    fi
    pr=$(single_pr "$branch")
    if [[ -z "$pr" ]]; then
      _empty_pr_line
      return
    fi
  fi
  number=$(echo "$pr" | jq -r '.number')
  state=$(echo "$pr" | jq -r '.state')
  checks=$(checks "$pr")
  printf "%-${PR_NUMBER_LENGTH}s │ %-${PR_STATE_LENGTH}s%s │ %-${CHECKS_LENGTH}s \n" "#$number" "$(pr_state "$state")" "${NC}" "$checks"
}
_empty_pr_line() {
  printf "%-${PR_NUMBER_LENGTH}s │ %-${PR_STATE_LENGTH}s%s │ %-${CHECKS_LENGTH}s \n"
}

checks() {
  local pr=$1 success failure pending
  success=$(echo "$pr" | _count_status "SUCCESS")
  failure=$(echo "$pr" | _count_status "FAILURE")
  pending=$(echo "$pr" | _count_status "PENDING")

  if [[ "$success" -gt 0 ]]; then
    printf "%2s ${GREEN}✓${NC}" "$success"
  fi
  if [[ "$failure" -gt 0 ]]; then
    printf "%2s ${RED}✗${NC}" "$failure"
  fi
  if [[ "$pending" -gt 0 ]]; then
    printf "%2s ${ORANGE}⊙${NC}" "$pending"
  fi
}

_count_status() {
  local status=$1
  jq -r 'def count(stream): reduce stream as $i (0; .+1); .statusCheckRollup | count(.[] | select(.conclusion == "'"$status"'"))'
}

pr_state() {
  local state=$1 color
  case $state in
    "OPEN") color="${GREEN}" ;;
    "CLOSED") color="${RED}" ;;
    "MERGED") color="${PURPLE}" ;;
    *) color="${ORANGE}" ;;
  esac
  printf "${color}%-${PR_STATE_LENGTH}s${NC}" "$state"
}

main "$@"
