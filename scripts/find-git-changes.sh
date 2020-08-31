#!/usr/bin/env bash

# Collect status on git repositories in listed directories

ERROR="Bad usage, see $0 -h"

read -r -d "" USAGE <<EOF
Collect status on git repositories in listed directories.

Outputs a table with status for each repo found.

Usage: ${0##*/} [-asSrfblh]
  -a          List all repos (default: only changed)
  -s          Show short stats
  -S          Show long stats
  -r          Check remote status
  -f          Run git fetch before comparing to remote
  -b          Show the checked out branch
  -l          Only list repos, dont show table
  -h          Show usage

Example:
  ${0##*/}

EOF

set -eo pipefail

while getopts asSrfblh opt; do
  case $opt in
    a) OPT_LIST_ALL=true                 ;;
    s) OPT_STATS=true                    ;;
    S) OPT_LONG_STATS=true               ;;
    r) OPT_CHECK_REMOTE=true             ;;
    f) OPT_FETCH=true                    ;;
    b) OPT_SHOW_BRANCH=true              ;;
    l) OPT_LIST_ONLY=true                ;;
    h) echo "$USAGE" && exit 0           ;;
    *) echo "$ERROR" && exit 1           ;;
  esac
done

# shellcheck disable=SC2034 # There may be a more elegant way to check for array support
whotest[0]='test' || (echo 'Failure: arrays not supported in this version of
bash.' && exit 2)

# Basic method
# DIR=$(dirname $0)

# Allows calling through symlink
DIR=$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")
# Source color script
. $DIR/colors.sh

BG_OK=${BG_GREEN}
BG_WARN=${BG_ORANGE}
BG_DANGER=${BG_RED}
BG_MISSING=${BG_LIGHT_GRAY}

# FG_OK=${FG_BLUE}
# FG_WARN=${FG_ORANGE}
# FG_DANGER=${FG_RED}
# FG_MISSING=${FG_LIGHT_GRAY}

function echo-ok() { printf "${BG_OK}${BLACK} %4d ${NC}" "$1"; }
function echo-warn() { printf "${BG_WARN}${BLACK} %4d ${NC}" "$1"; }
function echo-danger() { printf "${BG_DANGER}${BLACK} %4d ${NC}" "$1"; }
function echo-skip() { printf "${BG_MISSING}${DARK_GRAY} %4s ${NC}" "?"; }

function echo-remote-ok() { printf "${BG_OK}${BLACK} %4s ${NC}" "OK"; }
function echo-remote-missing() { printf "${BG_DANGER}${BLACK} %4s ${NC}" "!"; }
function echo-remote-offline() { printf "${BG_MISSING}${DARK_GRAY} %4s ${NC}" "X"; }
function echo-upstream-missing() { printf "${BG_DANGER}${BLACK} %4s ${NC}" "!"; }

function echo-red() { printf "${RED} %s ${NC}" "$*"; }
function echo-orange() { printf "${ORANGE} %s ${NC}" "$*"; }
function echo-gray() { printf "${LIGHT_GRAY} %s${NC}" "$*"; }

DIR_LIST=(
  "${HOME}/dev"
  "${HOME}/learn"
  "${HOME}/.dotfiles"
)

function warn_if_nonzero() {
  if [ "$1" -gt 0 ]; then
    echo-warn "$1"
  else
    echo-ok "$1"
  fi
}

function has_commits() {
  git rev-parse HEAD >/dev/null 2>&1
}

function get_branch() {
  git rev-parse --abbrev-ref HEAD
}

function print_git_branch() {
  local BRANCH
  if has_commits; then
    BRANCH=$(get_branch)
  else
    BRANCH="master?"
  fi

  printf "${LIGHT_GRAY}%s${NC}" "$BRANCH"
}

function git_header() {
  printf " %4s " "MOD"
  printf " %4s " "DEL"
  printf " %4s " "UNT"
  if [[ "$OPT_CHECK_REMOTE" == true ]]; then
    printf " %4s " "REM"
    printf " %4s " "CA"
    printf " %4s " "CB"
  fi
}

function print_git_stats() {
  set +e

  local NUM_MODIFIED
  local NUM_DELETED
  local NUM_UNTRACKED

  NUM_MODIFIED=$(git status --porcelain | grep -E "^ ?M" -c)
  NUM_DELETED=$(git status --porcelain | grep -E "^ ?D" -c)
  NUM_UNTRACKED=$(git status --porcelain | grep "^??" -c)

  warn_if_nonzero "$NUM_MODIFIED"
  warn_if_nonzero "$NUM_DELETED"
  warn_if_nonzero "$NUM_UNTRACKED"

  local BRANCH
  local REMOTE
  local UPSTREAM
  local LOCAL_AHEAD
  local UPSTREAM_AHEAD

  if has_commits; then
    BRANCH=$(get_branch)
  else
    echo-red '!'
    return
  fi

  if [[ "$OPT_CHECK_REMOTE" == true ]]; then
    REMOTE=$(git remote)
    if [ -z "$REMOTE" ]; then
      echo-remote-missing
      echo-skip
      echo-skip
    elif [[ "$OFFLINE" == true ]] || { [[ "$OPT_FETCH" == true ]] && ! git fetch >/dev/null 2>&1; }; then
      OFFLINE=true
      echo-remote-offline
      echo-skip
      echo-skip
    else
      echo-remote-ok

      # Remote is okay, now get status of upstream
      UPSTREAM=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)")

      if [ -z "$UPSTREAM" ]; then
        echo-upstream-missing
        echo-upstream-missing
      else
        LOCAL_AHEAD=$(git rev-list --left-only --count "$BRANCH"..."$UPSTREAM")
        UPSTREAM_AHEAD=$(git rev-list --right-only --count "$BRANCH"..."$UPSTREAM")
        warn_if_nonzero "$LOCAL_AHEAD"
        warn_if_nonzero "$UPSTREAM_AHEAD"
      fi
    fi
  fi
  set -e
}

if [[ ! "$OPT_LIST_ONLY" == true ]]; then
  git_header
fi
for dir in "${DIR_LIST[@]}"; do
  echo
  echo -e "${BLUE}=============================================${NC}"
  echo -e "${BLUE}= ${CYAN}${dir/$HOME/\~}${NC}"
  echo -e "${BLUE}=============================================${NC}"

  # Need bash v.4
  # readarray -t REPOS < <(find ${dir} -name ".git" -type d -maxdepth 3)

  REPOS=$(find "${dir}" -name ".git" -type d -maxdepth 3 | sed 's/\/.git$//')
  echo
  for repo in $REPOS; do

    cd "$repo"
    if [[ "$OPT_LIST_ALL" == true ]] || ! git diff-index --quiet HEAD -- 2>/dev/null; then
      NAME="${repo##*/}"
      REPO_PATH="${repo/$HOME/\~}"
      PARENT="${REPO_PATH/$NAME/}"
      if [[ ! "$OPT_LIST_ONLY" == true ]]; then
        print_git_stats
      fi
      echo-gray "$PARENT"
      echo-orange "$NAME"

      if [[ "$OPT_SHOW_BRANCH" == true ]]; then
        print_git_branch
      fi

      echo # Need a new line after printfs

      if [[ "$OPT_STATS" == true ]]; then
        git diff --shortstat
      elif [[ "$OPT_LONG_STATS" == true ]]; then
        git diff --stat --stat-width=80 --stat-name-width=40
      fi
    fi
  done
done
