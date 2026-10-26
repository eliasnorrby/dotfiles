#!/usr/bin/env bash
# Batched pull request lookups through `gh`. Pure definitions — nothing runs on
# source. Sourced by auto_branch_pruner and auto_worktree_pruner, which ask
# about hundreds of branches at once: one GraphQL query per PR_CHUNK branches
# instead of one `gh pr view` each.

# GitHub caps a query's cost, not its aliases; 50 lookups stay well inside it.
PR_CHUNK=50

# Fill the global associative array PR_STATE (branch -> OPEN, MERGED, CLOSED,
# or empty for no PR) for the given branches of the current directory's GitHub
# repository. A branch with several PRs counts as OPEN if any is open, else
# MERGED if any merged, else CLOSED. Returns non-zero if any query fails.
lookup_prs() {
  declare -gA PR_STATE
  local repo owner name
  repo=$(gh repo view --json owner,name --jq '.owner.login + " " + .name') || return 1
  read -r owner name <<<"$repo"

  local -a all=("$@") args
  local start i vars fields key state out
  for ((start = 0; start < ${#all[@]}; start += PR_CHUNK)); do
    # shellcheck disable=SC2016 # GraphQL variables, not shell ones
    vars='$owner: String!, $name: String!'
    fields=''
    args=(-f "owner=$owner" -f "name=$name")
    for ((i = start; i < start + PR_CHUNK && i < ${#all[@]}; i++)); do
      vars+=", \$b$i: String!"
      fields+=" b$i: pullRequests(headRefName: \$b$i, first: 20) { nodes { state } }"
      args+=(-f "b$i=${all[$i]}")
    done
    out=$(gh api graphql "${args[@]}" \
      -f query="query($vars) { repository(owner: \$owner, name: \$name) {$fields } }" \
      --jq '.data.repository | to_entries[]
        | [(.key | ltrimstr("b")),
           (.value.nodes | map(.state)
             | if index("OPEN") then "OPEN"
               elif index("MERGED") then "MERGED"
               elif index("CLOSED") then "CLOSED"
               else "" end)]
        | @tsv') || return 1
    while IFS=$'\t' read -r key state; do
      # shellcheck disable=SC2034 # read by the sourcing script
      PR_STATE[${all[$key]}]=$state
    done <<<"$out"
  done
}
