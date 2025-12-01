#!/usr/bin/env bash

usage() {
  cat <<-EOF >&2
	${0##*/} <list|diff> [file] [base_ref]

	List files changed on current branch, compared to a base branch. The base
	branch is guessed to be 'main' or 'master'. If none of them is found, lists
	changed files relative to HEAD instead.

	Arguments:
	  list|diff    Action to perform (default: list)
	  file         Optional file to diff (only used with 'diff' action)
	  base_ref     Optional base branch/commit to compare against
	               (e.g., to compare branch b against branch a, use 'branch_a')
	EOF
}

parse_args() {
  local action="$1"
  case "$action" in
    "") action="list" ;;
    list) action="list" ;;
    diff) action="diff" ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      usage
      exit 1
      ;;
  esac

  # Determine base_ref based on action
  # For 'list' action: $2 would be base_ref
  # For 'diff' action: $3 would be base_ref (since $2 is the file)
  local base_ref=""
  if [[ "$action" == "list" && -n "$2" ]]; then
    base_ref="$2"
  elif [[ "$action" == "diff" && -n "$3" ]]; then
    base_ref="$3"
  fi

  echo "$action:$base_ref"
}

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
  local base_branch cmd action merge_base base_ref parsed
  parsed=$(parse_args "$@")
  action="${parsed%%:*}"
  base_ref="${parsed#*:}"

  # Use provided base_ref or guess the base branch
  if [[ -n "$base_ref" ]]; then
    base_branch="$base_ref"
  else
    base_branch=$(guess_base_branch)
  fi

  cmd=(git)
  if [[ "$action" == "diff" ]]; then
    cmd+=(--no-pager)
  fi
  cmd+=(diff --diff-filter=ACMR)
  if [[ -n "$base_branch" ]]; then
    merge_base=$(git merge-base "$base_branch" HEAD)
    cmd+=(--relative "$merge_base")
  fi
  case $action in
    list)
      cmd+=(--name-only)
      "${cmd[@]}"
      ;;
    diff)
      "${cmd[@]}" "$2"
      ;;
  esac
}

main "$@"
