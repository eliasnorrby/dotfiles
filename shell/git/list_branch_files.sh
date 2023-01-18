#!/usr/bin/env bash

usage() {
  cat <<-EOF >&2
	${0##*/} <list|diff>

	List files changed on current branch, compared to the base branch. The base
	branch is guessed to be 'main' or 'master'. If none of them is found, lists
	changed files relative to HEAD instead.
	EOF
}

main() {
  local base_branch cmd action merge_base
  action=$(parse_args "$@")
  base_branch=$(guess_base_branch)
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

parse_args() {
  case "$1" in
    "") echo "list" ;;
    list) echo "list" ;;
    diff) echo "diff" ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

guess_base_branch() {
  for branch in main master; do
    if is_branch "$branch"; then
      echo "$branch"
      return
    fi
  done
}

is_branch() {
  git rev-parse --verify "$1" >/dev/null 2>&1
}

main "$@"
