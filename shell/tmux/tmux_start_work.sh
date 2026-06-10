#!/usr/bin/env bash
# Start (or resume) work on a task from a Linear branch on the clipboard.
#
# Copy Linear's suggested branch name (e.g. elias/bemlo-7370-spike-jsonforms),
# then this script:
#   - creates a worktree under <main>/.worktrees/<lowercase-id> checked out to
#     that branch (branching off the default branch when it doesn't exist yet),
#   - opens a tmux window cwd'd there and ties it via the @worktree option
#     (reusing go_to_worktree from worktree_lib.sh),
#   - annotates the window's @issue/@desc by reusing tmux_set_issue.
#
# Re-running on the same task just switches to the existing window. Meant to run
# in a tmux popup (see `bind N` in tmux.conf).
set -uo pipefail

# Shared helpers, installed on PATH by the git topic; located at run time.
# shellcheck disable=SC1090,SC1091
source "$(command -v worktree_lib.sh)" || {
  tmux display-message "worktree_lib.sh not found on PATH"
  exit 1
}

notify() {
  tmux display-message "$*"
}

# Surface an error in the popup (kept open until a keypress) and abort.
die() {
  printf '✗ %s\n' "$*" >&2
  notify "$*"
  printf '\nPress any key…'
  read -r -n1 _ || true
  exit 1
}

read_clipboard() {
  case "$OSTYPE" in
    darwin*) pbpaste 2>/dev/null ;;
    *) wl-paste -n 2>/dev/null ;;
  esac
}

# The remote's default branch (origin/master, origin/main, …) to branch off of.
default_branch() {
  local head b
  head=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null)
  if [ -n "$head" ]; then
    printf '%s' "$head"
    return
  fi
  for b in origin/master origin/main; do
    if git rev-parse --verify --quiet "$b" >/dev/null; then
      printf '%s' "$b"
      return
    fi
  done
}

# Create the worktree at $1 for branch $2, choosing the right git incantation
# depending on whether the branch exists locally, on the remote, or not at all.
create_worktree() {
  local dir=$1 branch=$2 base
  git fetch --quiet origin 2>/dev/null
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch" || die "git worktree add failed"
  elif git rev-parse --verify --quiet "origin/$branch" >/dev/null; then
    git worktree add "$dir" --track -b "$branch" "origin/$branch" \
      || die "git worktree add (tracking origin/$branch) failed"
  else
    base=$(default_branch)
    [ -n "$base" ] || die "Could not determine a base branch to fork from"
    # --no-track: the branch forks off origin/master but must not adopt it as
    # upstream (git would otherwise auto-track the remote start point).
    git worktree add --no-track -b "$branch" "$dir" "$base" \
      || die "git worktree add (new branch off $base) failed"
  fi
}

main() {
  local branch id dir main_root created=0 win

  branch=$(read_clipboard)
  branch=${branch#"${branch%%[![:space:]]*}"} # trim leading whitespace
  branch=${branch%"${branch##*[![:space:]]}"} # trim trailing whitespace
  [ -n "$branch" ] || die "Clipboard is empty — copy a branch name first"
  case "$branch" in
    *[[:space:]]*) die "Clipboard doesn't look like a branch: $branch" ;;
  esac

  is_in_git_repo || die "Not in a git repository"
  # Anchor at the main worktree (git lists it first), never the current one —
  # otherwise running this from inside a worktree nests .worktrees under it.
  main_root=$(main_worktree)

  # Worktree directory name: the lowercase Linear id when present (deterministic
  # per-issue path), else the branch minus its author prefix.
  if [[ "$branch" =~ ([A-Za-z]+-[0-9]+) ]]; then
    id=$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
  else
    id=${branch#*/}
  fi
  dir="$main_root/.worktrees/$id"

  if [ ! -d "$dir" ]; then
    create_worktree "$dir" "$branch"
    created=1
  fi

  # Open/switch to + tie a window (go_to_worktree comes from worktree_lib.sh).
  win=$(go_to_worktree "$dir")

  # Annotate only freshly created worktrees; resuming keeps existing annotations.
  if [ "$created" -eq 1 ]; then
    tmux_set_issue -t "$win" "$branch" || true
  fi
}

main "$@"
