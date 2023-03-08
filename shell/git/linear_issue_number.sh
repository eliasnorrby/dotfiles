#!/usr/bin/env bash

# This script will find the linear issue number from the current branch

# @param $1 - If set, will print a 'fixes: ' prefix

issue_number() {
  git branch --show-current | sed 's#[a-z]*/\([a-z]*-[0-9]*\).*#\1#' | tr '[:lower:]' '[:upper:]'
}

main() {
  local number
  number=$(issue_number)
  if [[ -n "$1" ]]; then
    echo "fixes: $number"
  else
    echo "$number"
  fi
}

main "$@"
