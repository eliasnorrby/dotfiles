#!/usr/bin/env bash

# This script will find the linear issue number from the current branch
# It looks for patterns like: user/TEAM-1234-description or TEAM-1234-description
# and extracts the issue ID (e.g., TEAM-1234)

# @param $1 - If set, will print a 'fixes: ' prefix, useful for pull request descriptions

issue_number() {
  local branch
  branch=$(git branch --show-current)

  # Match Linear issue pattern: one or more uppercase letters, hyphen, one or more digits
  # Pattern handles both: user/team-123-desc and team-123-desc
  if [[ "$branch" =~ ([A-Z]+-[0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  elif [[ "$branch" =~ ([a-z]+-[0-9]+) ]]; then
    # Also match lowercase and convert to uppercase
    echo "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]'
  fi
  # Return nothing if no match
}

main() {
  local number
  number=$(issue_number)

  if [[ -z "$number" ]]; then
    # No Linear issue found, exit silently
    exit 0
  fi

  if [[ -n "$1" ]]; then
    echo "fixes: $number"
  else
    echo "$number"
  fi
}

main "$@"
