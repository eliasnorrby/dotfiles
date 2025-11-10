#!/usr/bin/env bash

if ! command -v task >/dev/null 2>&1; then
  exit 0
fi

merge_count=$(task count status:pending +pr +merge -wait)
review_count=$(task count status:pending +pr +review -wait)
due_count=$(task count '(due:today or +OVERDUE)')
next_task=$(task rc.verbose: limit:1 started | head -1)
separator="#[fg=brightblack] • #[fg=default]"

components=()
if [[ -n "$next_task" ]]; then
  components+=("#[fg=yellow]  #[fg=default]$next_task")
fi

if [[ "$merge_count" -gt 0 ]]; then
  components+=("#[fg=green]  ${merge_count}#[fg=default]")
fi

if [[ "$review_count" -gt 0 ]]; then
  components+=("#[fg=yellow]  $review_count#[fg=default]")
fi

if [[ "$due_count" -gt 0 ]]; then
  components+=("#[fg=red] $due_count#[fg=default]")
fi

output=""
first=true

if [[ ${#components[@]} -gt 0 ]]; then
  for component in "${components[@]}"; do
    if [[ "$first" == true ]]; then
      output+="$component"
      first=false
    else
      output+="$separator$component"
    fi
  done
fi

echo "$output"
