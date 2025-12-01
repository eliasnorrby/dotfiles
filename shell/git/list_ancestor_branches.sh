#!/usr/bin/env bash

# Find branches that are ancestors of the current branch, between the current
# branch and the main branch. This excludes branches that diverged before the
# current branch's lineage.

is_branch() {
  git rev-parse --verify "$1" >/dev/null 2>&1
}

guess_base_branch() {
  for branch in main master; do
    if is_branch "$branch"; then
      echo "$branch"
      return
    fi
  done
}

main() {
  local current_branch base_branch merge_base_with_main
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  base_branch=$(guess_base_branch)

  if [[ -z "$base_branch" ]]; then
    # No main/master branch found
    exit 0
  fi

  # Get the merge base between current branch and main/master
  merge_base_with_main=$(git merge-base "$base_branch" HEAD)

  # Get all local branches
  git for-each-ref --format='%(refname:short)' refs/heads/ | while read -r branch; do
    # Skip current branch and base branch
    if [[ "$branch" == "$current_branch" || "$branch" == "$base_branch" ]]; then
      continue
    fi

    # Get merge base between this branch and current branch
    local branch_merge_base
    branch_merge_base=$(git merge-base "$branch" HEAD 2>/dev/null)

    local branch_main_merge_base
    branch_main_merge_base=$(git merge-base "$branch" "$base_branch" 2>/dev/null)

    # Skip if no merge base (shouldn't happen for local branches)
    if [[ -z "$branch_merge_base" || -z "$branch_main_merge_base" ]]; then
      continue
    fi

    # Check if the merge base between branch and HEAD is after merge_base_with_main
    # This means the branch is relevant to our lineage
    if git merge-base --is-ancestor "$merge_base_with_main" "$branch_merge_base" 2>/dev/null \
      && git merge-base --is-ancestor "$branch_main_merge_base" "$merge_base_with_main" 2>/dev/null; then
      # The branch is relevant - either an ancestor or a sibling that diverged
      # after our common ancestry with main
      echo "$branch"
    fi
  done
}

main "$@"
