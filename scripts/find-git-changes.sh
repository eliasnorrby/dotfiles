#!/usr/bin/env bash

# Collect status on git repositories in listed directories

ERROR="Bad usage, see $0 -h"

read -r -d "" USAGE <<EOF
Collect status on git repositories in listed directories

Usage: ${0##*/} [-h]
  -h          Show usage

Example:
  ${0##*/}

EOF

set -eo pipefail

while getopts h opt; do
  case $opt in
    h) echo "$USAGE" && exit 0             ;;
    *) echo "$ERROR" && exit 1             ;;
  esac
done

# Need bash v.4
# set +o posix

whotest[0]='test' || (echo 'Failure: arrays not supported in this version of
bash.' && exit 2)

# Source color script
. ./colors.sh

DIR_LIST=(
  "${HOME}/dev"
  "${HOME}/learn"
  "${HOME}/.dotfiles"
)

for dir in ${DIR_LIST[@]}; do
  echo
  echo -e "${BLUE}=============================================${NC}"
  echo -e "${BLUE}= ${CYAN}$dir${NC}"
  echo -e "${BLUE}=============================================${NC}"

  # TODO UPDATE BASH
  # short_dir=${dir##*/}
  # caps_dir=${short_dir^^}

  # echo
  # artii $caps_dir --font slant
  # echo

  # Need bash v.4
  # readarray -t REPOS < <(find ${dir} -name ".git" -type d -maxdepth 3)

  REPOS=$(find ${dir} -name ".git" -type d -maxdepth 3 | sed 's/\/.git$//')
  for repo in ${REPOS[@]}; do
    # cd ${repo/.git/}
    cd $repo
    if ! git diff-index --quiet HEAD --; then
      NAME="${repo##*/}"
      echo -e "${ORANGE}$NAME${NC} has changes"
      echo -e "${LIGHT_GRAY}${repo/$HOME/~}${NC}"
      git diff --shortstat
      # git diff --stat --stat-width=80 --stat-name-width=40
      echo
    fi
  done
done
