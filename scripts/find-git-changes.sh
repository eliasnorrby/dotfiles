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
    a) OPT_LIST_ALL=true                   ;;
    s) OPT_STATS=true                      ;;
    S) OPT_LONG_STATS=true                 ;;
    r) OPT_CHECK_REMOTE=true               ;;
    f) OPT_FETCH=true                      ;;
    b) OPT_SHOW_BRANCH=true                ;;
    l) OPT_LIST_ONLY=true                  ;;
    h) echo "$USAGE" && exit 0             ;;
    *) echo "$ERROR" && exit 1             ;;
  esac
done


whotest[0]='test' || (echo 'Failure: arrays not supported in this version of
bash.' && exit 2)

DIR=$(dirname $0)
# Source color script
. $DIR/colors.sh

BG_OK=${BG_BLUE}
BG_WARN=${BG_ORANGE}
BG_DANGER=${BG_RED}
BG_MISSING=${BG_LIGHT_GRAY}

FG_OK=${FG_BLUE}
FG_WARN=${FG_ORANGE}
FG_DANGER=${FG_RED}
FG_MISSING=${FG_LIGHT_GRAY}

function echo-ok  { printf "${BG_OK}${BLACK} %4d ${NC}" "$1"; }
function echo-warn  { printf "${BG_WARN}${BLACK} %4d ${NC}" "$1"; }
function echo-danger  { printf "${BG_DANGER}${BLACK} %4d ${NC}" "$1"; }
function echo-skip  { printf "${BG_MISSING}${DARK_GRAY} %4s ${NC}" "?"; }

function echo-remote-ok  { printf "${BG_OK}${BLACK} %4s ${NC}" "OK"; }
function echo-remote-missing  { printf "${BG_DANGER}${BLACK} %4s ${NC}" "!"; }
function echo-remote-offline  { printf "${BG_MISSING}${DARK_GRAY} %4s ${NC}" "X"; }
function echo-upstream-missing  { printf "${BG_DANGER}${BLACK} %4s ${NC}" "!"; }

function echo-orange  { printf "${ORANGE} %s ${NC}" "$*"; }
function echo-gray  { printf "${LIGHT_GRAY} %s${NC}" "$*"; }

DIR_LIST=(
  "${HOME}/dev"
  "${HOME}/learn"
  "${HOME}/.dotfiles"
)

function warn_or_ok {
  [ $1 -gt 0 ] && echo-warn $1 || echo-ok $1
}

function git_branch {
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)
  printf "${LIGHT_GRAY}%s${NC}" "$BRANCH"
}

function git_header {
  printf " %4s " "MOD"
  printf " %4s " "DEL"
  printf " %4s " "UNT"
  if [ "$OPT_CHECK_REMOTE" == true ] ; then
    printf " %4s " "REM"
    printf " %4s " "CA"
    printf " %4s " "CB"
  fi
}

function git_stats {
  set +e
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)

  local NUM_MODIFIED=$(git status --porcelain | grep -E "^ ?M" -c)
  local NUM_DELETED=$(git status --porcelain | grep -E "^ ?D" -c)
  local NUM_UNTRACKED=$(git status --porcelain | grep "^??" -c)

  warn_or_ok $NUM_MODIFIED
  warn_or_ok $NUM_DELETED
  warn_or_ok $NUM_UNTRACKED

  if [ "$OPT_CHECK_REMOTE" == true ] ; then
    local REMOTE=$(git remote)
    if [ -z "$REMOTE" ] ; then
      echo-remote-missing
      echo-skip
      echo-skip
    elif [ "$OFFLINE" == true ] || { [ "$OPT_FETCH" == true ] && ! git fetch > /dev/null 2>&1 ; } ; then
      OFFLINE=true
      echo-remote-offline
      echo-skip
      echo-skip
    else
      echo-remote-ok

      # Remote is okay, now get status of upstream
      local UPSTREAM=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)")

      if [ -z "$UPSTREAM" ] ; then
        echo-upstream-missing
        echo-upstream-missing
      else
        local LOCAL_AHEAD=$(git rev-list --left-only --count $BRANCH...$UPSTREAM)
        local UPSTREAM_AHEAD=$(git rev-list --right-only --count $BRANCH...$UPSTREAM)
        warn_or_ok $LOCAL_AHEAD
        warn_or_ok $UPSTREAM_AHEAD
      fi
    fi
  fi
  set -e
}

if [ ! "$OPT_LIST_ONLY" == true ] ; then
  git_header
fi
for dir in ${DIR_LIST[@]}; do
  # echo
  # echo -e "${BLUE}=============================================${NC}"
  # echo -e "${BLUE}= ${CYAN}${dir/$HOME/\~}${NC}"
  # echo -e "${BLUE}=============================================${NC}"

  # TODO UPDATE BASH
  # short_dir=${dir##*/}
  # caps_dir=${short_dir^^}

  # echo
  # artii $caps_dir --font slant
  # echo

  # Need bash v.4
  # readarray -t REPOS < <(find ${dir} -name ".git" -type d -maxdepth 3)

  REPOS=$(find ${dir} -name ".git" -type d -maxdepth 3 | sed 's/\/.git$//')
  echo
  for repo in ${REPOS[@]}; do

    cd $repo
    if [ "$OPT_LIST_ALL" == true ] || ! git diff-index --quiet HEAD --; then
      NAME="${repo##*/}"
      REPO_PATH="${repo/$HOME/\~}"
      PARENT="${REPO_PATH/$NAME/}"
      if [ ! "$OPT_LIST_ONLY" == true ] ; then
        git_stats
      fi
      echo-gray $PARENT
      echo-orange $NAME

      if [ "$OPT_SHOW_BRANCH" == true ] ; then
        git_branch
      fi

      echo # Need a new line after printfs

      if [ "$OPT_STATS" == true ] ; then
        git diff --shortstat
      elif [ "$OPT_LONG_STATS" == true ] ; then
        git diff --stat --stat-width=80 --stat-name-width=40
      fi
    fi
  done
done
