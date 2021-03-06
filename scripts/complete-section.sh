#!/usr/bin/env bash
#
# This script is a convenience tool for saving progress in an online course
# to a git repository.
DIR=$(dirname $([ -L "$0" ] && readlink -f "$0" || echo $0))
[ -f $DIR/echos.sh ] && . $DIR/echos.sh || (echo "Could not source 'echos', aborting" && exit 1)

set -e

if [ ! -d .git ] ; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
  cd "$PROJECT_ROOT"
fi

ARG_NUMBER=$1

## Variables
LECTURE_COUNTER=$(pwd)/lecture_counter
DEFAULT_MSG_BASE="L"

## Functions
validate_number() {
  local REGEX='^[0-9]+$'
  if ! [[ $1 =~ $REGEX ]] ; then
     echo-fail "error: Not a number" >&2; return 1
  fi
}

read_lecture_counter() {
  if [ ! -f $LECTURE_COUNTER ] ; then
    return
  else
    local COMPLETED_LECTURE=$(cat $LECTURE_COUNTER)
    if ! validate_number "$COMPLETED_LECTURE" ; then
      return
    fi
    echo $COMPLETED_LECTURE
  fi
}

increment_counter() {
  if [ ! -f $LECTURE_COUNTER ] ; then
    echo-info "No counter file found. Creating..."
  fi

  if [ ! -z "$ARG_NUMBER" ] ; then
    if validate_number $ARG_NUMBER ; then
      echo $ARG_NUMBER > $LECTURE_COUNTER
      return
    else
      echo-fail "That's not a number: $ARG_NUMBER"
    fi
  fi

  if [ ! -f $LECTURE_COUNTER ] || [ ! -z "$ARG_NUMBER" ] ; then
    local INPUT_NUMBER=""
    while [ -z "$INPUT_NUMBER" ] || ! validate_number $INPUT_NUMBER ; do
      read -p "Which lecture is this? " INPUT_NUMBER
    done
    echo-info "Setting lecture counter to: $INPUT_NUMBER"
    echo $INPUT_NUMBER > $LECTURE_COUNTER
  else
    local INPUT_NUMBER=$(read_lecture_counter)
    echo-info "Incrementing lecture counter: $INPUT_NUMBER -> $((INPUT_NUMBER+1))"
    echo $((INPUT_NUMBER+1)) > lecture_counter
  fi
}

cleanup() {
  echo
  echo-info "Cleaning up..."
  if [ -f $LECTURE_COUNTER ] ; then
    echo-info "Resetting the lecture counter"
    {
      git reset $LECTURE_COUNTER
      git checkout $LECTURE_COUNTER 2>&1
    } > /dev/null
  fi
  exit 1
}

trap cleanup ERR SIGINT

## 1: Read or otherwise determine lecture number
increment_counter


LECTURE_NUMBER=$(read_lecture_counter)
BASE_MSG="Enter a description"
VIM_MSG="type 'v' to edit in vim"
if [ -z "$LECTURE_NUMBER" ] ; then
  # This branch shouldn't happen any more
  EXTENDED_MSG="e.g. 'Complete lecture 12'"
  while [ -z "$MSG" ]; do
    echo-input
    read -p "$BASE_MSG ($EXTENDED_MSG): " MSG
  done
else
  # DEFAULT_MSG="Complete lecture $((LECTURE_NUMBER+1))"
  DEFAULT_MSG="${DEFAULT_MSG_BASE}${LECTURE_NUMBER}"
  EXTENDED_MSG="default: '$DEFAULT_MSG'"
  echo-input
  read -p "$BASE_MSG ($EXTENDED_MSG) ($VIM_MSG): " MSG
  if [ -z "$MSG" ] ; then
    MSG=$DEFAULT_MSG
  elif [[ "$MSG" == "v" ]] ; then
    OPT_EDIT_MSG=true
    MSG="<to be edited in vim>"
  else
    MSG="${DEFAULT_MSG}: $MSG"
  fi
fi

## 2: Stage changes and print status, await confirmation
### Check for repo
git status 2>&1 > /dev/null
if [ "$?" -ne 0 ]; then
  echo-fail "Not a git repository! Have you completed the setup yet?"
  exit 1
fi

### Check for changes
if git diff-index --quiet HEAD --; then
  echo-info "No local changes found."
else
  echo-info "Found local changes!"
fi


git add -A
git status --short

echo-info "Staged all changes."
echo-info "Commit message: $MSG"

## 3: Commit and push the changes
PROMPT_MSG="Commit changes? [y/n] "
echo-input
read -p "$PROMPT_MSG" -n 1 -r CHOICE
echo
YES_NO_REGEXP='([yY]|[yY][eE][sS]|[nN]|[nN][oO])'
while [[ ! $CHOICE =~ $YES_NO_REGEXP ]]; do
  echo-fail "Please type y or n"
  echo-input
  read -p "$PROMPT_MSG" -n 1 -r CHOICE
  echo
done

case $CHOICE in
  [yY]|[yY][eE][sS])
    echo-info "Committing changes"
    if [[ "$OPT_EDIT_MSG" == true ]] ; then
      git commit -vem "${DEFAULT_MSG}: "
    else
      git commit -m "$MSG"
    fi
    ;;
  [nN]|[nN][oO])
    echo-info "Aborting"
    cleanup
    exit 0
    ;;
  *)
    echo-fail "Invalid choice"
    exit 1
    ;;
esac

PROMPT_MSG="Push to remote? [y/n] "
echo-input
read -p "$PROMPT_MSG" -n 1 -r CHOICE
echo
YES_NO_REGEXP='([yY]|[yY][eE][sS]|[nN]|[nN][oO])'
while [[ ! $CHOICE =~ $YES_NO_REGEXP ]]; do
  echo-fail "Please type y or n"
  echo-input
  read -p "$PROMPT_MSG" -n 1 -r CHOICE
  echo
done

case $CHOICE in
  [yY]|[yY][eE][sS])
    echo-info "Pushing changes"
    git push
    ;;
  [nN]|[nN][oO])
    echo-skip "Skipping pushing"
    ;;
  *)
    echo-fail "Invalid choice"
    exit 1
    ;;
esac

