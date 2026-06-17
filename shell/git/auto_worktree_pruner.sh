#!/usr/bin/env bash
# Prune worktrees whose branch is tied to a merged or closed PR.
#
# Worktree analogue of auto_branch_pruner: for each worktree (skipping the main
# one and the one you're standing in), it looks up the PR for the checked-out
# branch via `gh` and, when that PR is MERGED or CLOSED, removes the worktree
# and deletes its branch. Worktrees with uncommitted changes are left untouched
# (plain `git worktree remove`, no --force) and reported as "dirty", so work is
# never silently discarded.
set -uo pipefail

# Shared helpers (main_worktree, is_in_git_repo), installed on PATH by the git
# topic; located at run time.
# shellcheck disable=SC1090,SC1091
source "$(command -v worktree_lib.sh)" || {
  echo "worktree_lib.sh not found on PATH" >&2
  exit 1
}

ORANGE=$(tput setaf 3)
PURPLE=$(tput setaf 5)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
NC=$(tput sgr 0) # No Color

STATE_LENGTH=8
ACTION_LENGTH=8

main() {
  is_in_git_repo || {
    echo "Not in a git repository" >&2
    exit 1
  }

  MAIN_ROOT=$(main_worktree)
  CURRENT=$(git rev-parse --show-toplevel)

  # Gather rows up front so we can size the name/branch columns to their widest
  # entry (header labels seed the minimum widths).
  local -a paths names branches
  NAME_LENGTH=8   # "worktree"
  BRANCH_LENGTH=6 # "branch"
  local path branch name
  while IFS=$'\t' read -r path branch; do
    name=$(worktree_label "$path" "$MAIN_ROOT")
    paths+=("$path")
    names+=("$name")
    branches+=("$branch")
    [[ ${#name} -gt $NAME_LENGTH ]] && NAME_LENGTH=${#name}
    [[ ${#branch} -gt $BRANCH_LENGTH ]] && BRANCH_LENGTH=${#branch}
  done < <(list_worktrees)

  print_header

  local i
  for i in "${!paths[@]}"; do
    process "${paths[$i]}" "${names[$i]}" "${branches[$i]}"
  done
}

# Emit "<path>\t<branch>" per worktree; branch is empty for a detached HEAD.
# Bare entries (no branch and no detached line) are dropped.
list_worktrees() {
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10); branch = ""; detached = 0 }
    /^branch /   { branch = substr($0, 8); sub(/^refs\/heads\//, "", branch) }
    /^detached$/ { detached = 1 }
    /^$/         { if (branch != "" || detached) print path "\t" branch }
  '
}

process() {
  local path=$1 name=$2 branch=$3 state
  printf "${ORANGE}%-${NAME_LENGTH}s${NC} │ ${ORANGE}%-${BRANCH_LENGTH}s${NC} │ " "$name" "$branch"

  # Never touch the main worktree or the one this script is running from —
  # removing the latter would pull the rug out from the caller's shell.
  if [[ "$path" == "$MAIN_ROOT" ]]; then
    print_state "main"
    skip
    return
  fi
  if [[ "$path" == "$CURRENT" ]]; then
    print_state "current"
    skip
    return
  fi
  if [[ -z "$branch" ]]; then
    print_state "detached"
    skip
    return
  fi

  state=$(gh pr view "$branch" --json state --jq .state 2>/dev/null)
  [[ -z "$state" ]] && state="no PR"
  print_state "$state"

  if [[ "$state" == "MERGED" ]] || [[ "$state" == "CLOSED" ]]; then
    prune "$path" "$branch"
  else
    skip
  fi
}

# Remove the worktree and delete its branch. Plain `git worktree remove` (no
# --force) bails on a dirty or locked worktree, leaving it for the user. Run
# from the main worktree so git's cwd is never the directory being removed.
prune() {
  local path=$1 branch=$2
  if ! git -C "$MAIN_ROOT" worktree remove "$path" 2>/dev/null; then
    printf "${ORANGE}%s${NC}\n" "dirty"
    return
  fi
  # The worktree is gone, so the branch is no longer checked out anywhere and
  # is free to delete.
  git -C "$MAIN_ROOT" branch -D "$branch" >/dev/null 2>&1
  printf "${RED}%s${NC}\n" "removed"
}

skip() {
  printf "${CYAN}%s${NC}\n" "skipping"
}

print_header() {
  printf "%-${NAME_LENGTH}s │ %-${BRANCH_LENGTH}s │ %-${STATE_LENGTH}s │ %-${ACTION_LENGTH}s\n" \
    "worktree" "branch" "state" "action"
  printf "%-${NAME_LENGTH}s ┼ %-${BRANCH_LENGTH}s ┼ %-${STATE_LENGTH}s ┼ %-${ACTION_LENGTH}s\n" \
    | sed 's/ /─/g'
}

print_state() {
  local state=$1 color
  case "$state" in
    MERGED) color=${PURPLE} ;;
    CLOSED) color=${RED} ;;
    OPEN) color=${GREEN} ;;
    *) color=${CYAN} ;;
  esac
  printf "${color}%-${STATE_LENGTH}s${NC} │ " "$state"
}

main
