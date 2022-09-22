#!/usr/bin/env bash

export GH_FORCE_TTY='50%'

STATES="open\nall\nmerged\nclosed"

select_state() {
  echo -e "$STATES" | fzf --prompt="States: " --reverse
}

select_pr() {
  local state=$1
  gh pr list --state="$state" \
    | fzf --ansi --prompt="PR: " --reverse --header-lines 3 --preview 'gh pr view {1}' \
    | awk '{print $1}' | sed 's/^#//'
}

main() {
  local state pr_number
  state=$(select_state)
  if [[ -z "$state" ]]; then
    return
  fi
  pr_number=$(select_pr "$state")
  if [[ -z "$pr_number" ]]; then
    return
  fi
  gh browse "$pr_number"
}

main
