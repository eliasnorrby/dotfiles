#!/usr/bin/env bash

# This script opens the Linear issue URL for the current branch

main() {
  local issue_id
  issue_id=$(linear_issue_number)

  if [[ -z "$issue_id" ]]; then
    echo "No Linear issue found in current branch"
    exit 1
  fi

  # Use Linear's custom URL scheme to open directly in the app
  local url="linear://bemlo/issue/${issue_id}"

  # Open URL using the appropriate command based on platform
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$url"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "$url"
  else
    echo "Unsupported platform: $OSTYPE"
    exit 1
  fi
}

main "$@"
