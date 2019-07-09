#!/bin/bash
#
# This script is a convenience tool for saving progress in an online course
# to a git repository.
set -e

## Variables
LECTURE_COUNTER=$(pwd)/lecture_counter

## Functions
validate_number() {
  local REGEX='^[0-9]+$'
  if ! [[ $1 =~ $REGEX ]] ; then
     echo "error: Not a number" >&2; return 1
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
    echo "No counter file found. Creating..."
    local INPUT_NUMBER=""
    while [ -z "$INPUT_NUMBER" ] || ! validate_number $INPUT_NUMBER ; do
      read -p "Which lecture is this? " INPUT_NUMBER
    done
    echo "Creating new lecture counter: $INPUT_NUMBER"
    echo $INPUT_NUMBER > $LECTURE_COUNTER
  else
    local INPUT_NUMBER=$(read_lecture_counter)
    echo "Incrementing lecture counter: $INPUT_NUMBER -> $((INPUT_NUMBER+1))"
    echo $((INPUT_NUMBER+1)) > lecture_counter
  fi
}

cleanup() {
  echo "Cleaning up..."
  if [ -f $LECTURE_COUNTER ] ; then
    echo "Resetting the lecture counter"
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

if [ ! -z "$1" ] ; then
  MSG="$1"
else
  LECTURE_NUMBER=$(read_lecture_counter)
  BASE_MSG="Enter a description"
  if [ -z "$LECTURE_NUMBER" ] ; then
    EXTENDED_MSG="e.g. 'Complete lecture 12'"
    while [ -z "$MSG" ]; do
      read -p "$BASE_MSG ($EXTENDED_MSG): " MSG
    done
  else
    # DEFAULT_MSG="Complete lecture $((LECTURE_NUMBER+1))"
    DEFAULT_MSG="Complete lecture $LECTURE_NUMBER"
    EXTENDED_MSG="default: '$DEFAULT_MSG'"
    read -p "$BASE_MSG ($EXTENDED_MSG): " MSG
    if [ -z "$MSG" ] ; then
      MSG=$DEFAULT_MSG
    fi
  fi
fi

## 2: Stage changes and print status, await confirmation
### Check for repo
git status 2>&1 > /dev/null
if [ "$?" -ne 0 ]; then
  echo "Not a git repository! Have you completed the setup yet?"
  exit 1
fi

### Check for changes
if git diff-index --quiet HEAD --; then
  echo "No local changes found."
else
  echo "Found local changes!"
fi


git add -A
git status

echo "Staged all changes."
echo "Commit message: $MSG"

PROMPT_MSG="Commit and push to remote? [y/n] "
read -p "$PROMPT_MSG" CHOICE
YES_NO_REGEXP='([yY]|[yY][eE][sS]|[nN]|[nN][oO])'
while [[ ! $CHOICE =~ $YES_NO_REGEXP ]]; do
  echo "Please type y or n"
  read -p "$PROMPT_MSG" CHOICE
done

case $CHOICE in
  [yY]|[yY][eE][sS])
    echo "Committing and pushing the changes"
    ;;
  [nN]|[nN][oO])
    echo "Aborting"
    cleanup
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

## 3: Commit and push the changes
git commit -m "$MSG"
git push

