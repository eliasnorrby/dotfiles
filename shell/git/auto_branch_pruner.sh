#!/usr/bin/env bash

ORANGE=$(tput setaf 3)
PURPLE=$(tput setaf 5)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
NC=$(tput sgr 0) # No Color

main() {
  local branches maxlength

  branches=$(list_branches)

  for branch in $branches; do
    if [[ ${#branch} -gt $maxlength ]]; then
      maxlength=${#branch}
    fi
  done

  for branch in $branches; do
    printf "branch: ${ORANGE}%-${maxlength}s${NC} | " "$branch"
    if is_merged_or_closed "$branch" || is_stack "$branch"; then
      printf "action: ${RED}%s${NC}\n" "deleting"
      delete_branch "$branch"
    else
      printf "action: ${CYAN}%s${NC}\n" "skipping"
    fi
  done
}

list_branches() {
  git branch --format '%(refname:short)' | grep -vE '^local'
}

is_merged_or_closed() {
  local branch=$1 state
  state=$(gh pr view "$branch" --json state --jq .state 2>/dev/null)
  print_state "$state"
  if [[ "$state" == "MERGED" ]] || [[ "$state" == "CLOSED" ]]; then
    return 0
  else
    return 1
  fi
}

is_stack() {
  local branch=$1
  if [[ "$branch" == *_stack ]]; then
    print_state "STACK"
    return 0
  else
    return 1
  fi
}

delete_branch() {
  local branch=$1
  git branch -D "$branch"
}

print_state() {
  local state=$1 width=7 color
  if [[ -z "$state" ]]; then
    state="no PR"
    printf "state: %-${width}s | " "$state"
    return
  fi

  if [[ "$state" == "MERGED" ]]; then
    color=${PURPLE}
  elif [[ "$state" == "CLOSED" ]]; then
    color=${RED}
  elif [[ "$state" == "OPEN" ]]; then
    color=${GREEN}
  fi
  printf "state: ${color}%-${width}s${NC} | " "$state"
}

main
