#!/usr/bin/env bash
# Prune worktrees whose work has landed: their PR is merged or closed.
#
# Worktree analogue of auto_branch_pruner. A worktree can hold several branches
# over its life (a stack of PRs opened from one checkout), so it is judged by
# all of them: every branch its HEAD reflog has switched to or from, plus the
# one checked out now. It goes only when the checked-out branch's PR is MERGED
# or CLOSED and none of those branches still has an OPEN PR. The PR lookup is
# one batched GraphQL query per 50 branches, not one `gh` call per branch.
#
# A worktree is also kept when it is the main one, the one you're standing in,
# detached, locked, open in a tmux pane (a shell there would be left in a
# deleted directory) or dirty (plain `git worktree remove`, no --force, so
# work is never silently discarded). Removing a worktree also deletes its
# checked-out branch; the other branches it held are auto_branch_pruner's.
#
# Usage: auto_worktree_pruner [-n]
#   -n  dry run: print what would be removed, remove nothing
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
DIM=$(tput dim)
NC=$(tput sgr 0) # No Color

STATE_LENGTH=8
ACTION_LENGTH=12

# GitHub caps a query's cost, not its aliases; 50 lookups stay well inside it.
CHUNK=50

DRY_RUN=false

declare -A PR_STATE # branch -> OPEN, MERGED, CLOSED or empty (no PR)

main() {
  local opt
  while getopts n opt; do
    case "$opt" in
      n) DRY_RUN=true ;;
      *)
        echo "usage: auto_worktree_pruner [-n]" >&2
        exit 2
        ;;
    esac
  done

  is_in_git_repo || {
    echo "Not in a git repository" >&2
    exit 1
  }

  MAIN_ROOT=$(main_worktree)
  CURRENT=$(git rev-parse --show-toplevel)
  DEFAULT_BRANCH=$(git -C "$MAIN_ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
  DEFAULT_BRANCH=${DEFAULT_BRANCH#origin/}

  # Gather rows up front so we can size the name/branch columns to their widest
  # entry (header labels seed the minimum widths), and so every branch can be
  # looked up in one batch.
  local -a paths names branches flags held
  local -A wanted
  NAME_LENGTH=8   # "worktree"
  BRANCH_LENGTH=6 # "branch"
  local path branch flag name b
  local -a held_here
  while IFS=$'\t' read -r path branch flag; do
    name=$(worktree_label "$path" "$MAIN_ROOT")
    paths+=("$path")
    names+=("$name")
    branches+=("$branch")
    flags+=("$flag")
    [[ ${#name} -gt $NAME_LENGTH ]] && NAME_LENGTH=${#name}
    [[ ${#branch} -gt $BRANCH_LENGTH ]] && BRANCH_LENGTH=${#branch}

    mapfile -t held_here < <(held_branches "$path" "$branch")
    held+=("${held_here[*]}")
    for b in "${held_here[@]}"; do wanted[$b]=1; done
  done < <(list_worktrees)

  if [[ ${#wanted[@]} -gt 0 ]]; then
    lookup_prs "${!wanted[@]}" || {
      echo "PR lookup failed; nothing removed" >&2
      exit 1
    }
  fi

  OPEN_PATHS=$(open_paths)

  print_header

  local i
  for i in "${!paths[@]}"; do
    process "${paths[$i]}" "${names[$i]}" "${branches[$i]}" "${flags[$i]}" "${held[$i]}"
  done
}

# Emit "<path>\t<branch>\t<flag>" per worktree; branch is empty for a detached
# HEAD, flag is "locked" or empty. Bare entries (no branch and no detached
# line) are dropped.
list_worktrees() {
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10); branch = ""; detached = 0; flag = "" }
    /^branch /   { branch = substr($0, 8); sub(/^refs\/heads\//, "", branch) }
    /^detached$/ { detached = 1 }
    /^locked/    { flag = "locked" }
    /^$/         { if (branch != "" || detached) print path "\t" branch "\t" flag }
  '
}

# The branches a worktree has held: the one checked out now, plus both ends of
# every "checkout: moving from A to B" in its HEAD reflog. Commit ids (detached
# checkouts) and the default branch are left out. Reflog entries expire with
# gc.reflogExpire, so this is the recent history, not all of it.
held_branches() {
  local path=$1 branch=$2
  {
    [[ -n "$branch" ]] && printf '%s\n' "$branch"
    git -C "$path" reflog show HEAD --format=%gs 2>/dev/null \
      | sed -n 's/^checkout: moving from \(.*\) to \(.*\)$/\1\n\2/p'
  } | grep -vxE '[0-9a-f]{7,40}|HEAD' | grep -vxF "${DEFAULT_BRANCH:-HEAD}" | sort -u
}

# Fill PR_STATE for the given branches. A branch with several PRs counts as
# OPEN if any is open, else MERGED if any merged, else CLOSED.
lookup_prs() {
  local repo owner name
  repo=$(gh repo view --json owner,name --jq '.owner.login + " " + .name') || return 1
  read -r owner name <<<"$repo"

  local -a all=("$@") args
  local start i vars fields key state out
  for ((start = 0; start < ${#all[@]}; start += CHUNK)); do
    # shellcheck disable=SC2016 # GraphQL variables, not shell ones
    vars='$owner: String!, $name: String!'
    fields=''
    args=(-f "owner=$owner" -f "name=$name")
    for ((i = start; i < start + CHUNK && i < ${#all[@]}; i++)); do
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
      PR_STATE[${all[$key]}]=$state
    done <<<"$out"
  done
}

# Every directory a tmux pane is in, one per line; empty without a server.
open_paths() {
  tmux list-panes -a -F '#{pane_current_path}' 2>/dev/null
}

is_open_in_tmux() {
  local path=$1 p
  while IFS= read -r p; do
    [[ "$p" == "$path" || "$p" == "$path"/* ]] && return 0
  done <<<"$OPEN_PATHS"
  return 1
}

process() {
  local path=$1 name=$2 branch=$3 flag=$4 state b
  local -a others
  read -ra others <<<"$5"
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

  state=${PR_STATE[$branch]-}
  print_state "${state:-no PR}"

  if [[ "$state" != "MERGED" ]] && [[ "$state" != "CLOSED" ]]; then
    skip
    return
  fi
  for b in "${others[@]}"; do
    if [[ "${PR_STATE[$b]-}" == "OPEN" ]]; then
      skip "$b is open"
      return
    fi
  done
  if [[ "$flag" == "locked" ]]; then
    keep "locked"
    return
  fi
  if is_open_in_tmux "$path"; then
    keep "in tmux"
    return
  fi
  if [[ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]]; then
    keep "dirty"
    return
  fi

  prune "$path" "$branch"
}

# Remove the worktree and delete its branch. Run from the main worktree so
# git's cwd is never the directory being removed.
prune() {
  local path=$1 branch=$2
  if $DRY_RUN; then
    printf "${RED}%s${NC}\n" "would remove"
    return
  fi
  if ! git -C "$MAIN_ROOT" worktree remove "$path" 2>/dev/null; then
    keep "failed"
    return
  fi
  # The worktree is gone, so the branch is no longer checked out anywhere and
  # is free to delete.
  git -C "$MAIN_ROOT" branch -D "$branch" >/dev/null 2>&1
  printf "${RED}%s${NC}\n" "removed"
}

skip() {
  local note=${1-}
  printf "${CYAN}%-${ACTION_LENGTH}s${NC}" "skipping"
  [[ -n "$note" ]] && printf " ${DIM}%s${NC}" "$note"
  printf "\n"
}

# A finished worktree held back by something you can fix.
keep() {
  printf "${ORANGE}%s${NC}\n" "$1"
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

main "$@"
