#!/usr/bin/env bash
# Delete local branches whose work has landed: their PR is merged or closed.
# Branches named *_stack are deleted whatever their state, and local* ones are
# never considered. A branch checked out in a worktree is left alone (git
# refuses to delete it); auto_worktree_pruner removes those worktrees. The PR
# lookup is one batched GraphQL query per 50 branches, not a `gh` call each.
#
# Usage: auto_branch_pruner [-n]
#   -n  dry run: print what would be deleted, delete nothing
set -uo pipefail

# Batched PR lookups, installed on PATH by the git topic; located at run time.
# shellcheck disable=SC1090,SC1091
source "$(command -v pr_lib.sh)" || {
  echo "pr_lib.sh not found on PATH" >&2
  exit 1
}

ORANGE=$(tput setaf 3)
PURPLE=$(tput setaf 5)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
NC=$(tput sgr 0) # No Color

STATE_LENGTH=7
ACTION_LENGTH=12

DRY_RUN=false

declare -A PR_STATE # filled by lookup_prs

main() {
  local opt
  while getopts n opt; do
    case "$opt" in
      n) DRY_RUN=true ;;
      *)
        echo "usage: auto_branch_pruner [-n]" >&2
        exit 2
        ;;
    esac
  done

  git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "Not in a git repository" >&2
    exit 1
  }

  # branch -> the worktree it is checked out in, if any
  local -a branches
  local -A checked_out
  local branch path maxlength=6 # "branch"
  while IFS=$'\t' read -r branch path; do
    [[ "$branch" == local* ]] && continue
    branches+=("$branch")
    checked_out[$branch]=$path
    [[ ${#branch} -gt $maxlength ]] && maxlength=${#branch}
  done < <(git for-each-ref --format=$'%(refname:short)\t%(worktreepath)' refs/heads)

  if [[ ${#branches[@]} -gt 0 ]]; then
    lookup_prs "${branches[@]}" || {
      echo "PR lookup failed; nothing deleted" >&2
      exit 1
    }
  fi

  printf "%-${maxlength}s │ %-${STATE_LENGTH}s │ %-${ACTION_LENGTH}s\n" "branch" "state" "action"
  printf "%-${maxlength}s ┼ %-${STATE_LENGTH}s ┼ %-${ACTION_LENGTH}s\n" | sed 's/ /─/g'

  local state
  for branch in "${branches[@]}"; do
    printf "${ORANGE}%-${maxlength}s${NC} │ " "$branch"
    if [[ "$branch" == *_stack ]]; then
      state=STACK
    else
      state=${PR_STATE[$branch]-}
    fi
    print_state "$state"

    if [[ "$state" != "STACK" ]] && [[ "$state" != "MERGED" ]] && [[ "$state" != "CLOSED" ]]; then
      printf "${CYAN}%s${NC}\n" "skipping"
    elif [[ -n "${checked_out[$branch]}" ]]; then
      printf "${ORANGE}%s${NC}\n" "in worktree"
    elif $DRY_RUN; then
      printf "${RED}%s${NC}\n" "would delete"
    elif git branch -D "$branch" >/dev/null 2>&1; then
      printf "${RED}%s${NC}\n" "deleted"
    else
      printf "${ORANGE}%s${NC}\n" "failed"
    fi
  done
}

print_state() {
  local state=$1 color
  case "$state" in
    MERGED) color=${PURPLE} ;;
    CLOSED | STACK) color=${RED} ;;
    OPEN) color=${GREEN} ;;
    *) color=${CYAN} ;;
  esac
  printf "${color}%-${STATE_LENGTH}s${NC} │ " "${state:-no PR}"
}

main "$@"
