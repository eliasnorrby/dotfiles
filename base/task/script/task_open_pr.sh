#!/usr/bin/env bash

set -eo pipefail

# Script to open a GitHub PR in the browser from a taskwarrior task
# Expects task UUID as argument (passed by taskwarrior-tui)

# Check if task UUID is provided
if [ $# -eq 0 ]; then
  echo "Error: No task UUID provided" >&2
  exit 1
fi

task_uuid="$1"

# Export task data as JSON
task_data=$(task "$task_uuid" export 2>/dev/null)

if [ -z "$task_data" ] || [ "$task_data" = "[]" ]; then
  echo "Error: Task not found: $task_uuid" >&2
  exit 1
fi

# Extract PR number and repo from task
pr_number=$(echo "$task_data" | jq -r '.[0].pr_number // empty')
pr_repo=$(echo "$task_data" | jq -r '.[0].pr_repo // empty')

# Validate we have the required data
if [ -z "$pr_number" ] || [ "$pr_number" = "null" ]; then
  echo "Error: Task does not have a pr_number UDA" >&2
  exit 1
fi

if [ -z "$pr_repo" ] || [ "$pr_repo" = "null" ]; then
  echo "Error: Task does not have a pr_repo UDA" >&2
  exit 1
fi

# Open PR in browser using gh
if ! gh pr view "$pr_number" --repo "$pr_repo" --web; then
  echo "Error: Failed to open PR#$pr_number in $pr_repo" >&2
  exit 1
fi
