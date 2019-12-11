#!/usr/bin/env bash

# Bootstrap a node project with my personal configurations for
# prettier, commitlint and semantic release.

ERROR="Bad usage, see $0 -h"

read -r -d "" USAGE <<EOF
Bootstrap a node project with personal tool configurations.

Steps:
  1. Initialize local & remote repo
  2. Create README with Travis & npm badges
  3. Run semantic-release-cli setup
  4. Install configurations for
     - prettier
     - commitlint
     - semantic-release

Usage: ${0##*/} [-p]
  -p          Make the remote repository private
  -h          Show usage

Example:
  ${0##*/} -p

EOF

set -eo pipefail

while getopts p: opt; do
  case $opt in
    p) HUB_FLAGS="-p"                      ;;
    *) echo "$ERROR" && exit 1             ;;
  esac
done

if ! command -v npm >/dev/null 2>&1 ; then
  echo "Could not find npm in path, aborting"
  exit 1
fi

if ! command -v hub >/dev/null 2>&1 ; then
  echo "Could not find hub in path, aborting"
  exit 1
fi

if ! command -v semantic-release-cli >/dev/null 2>&1 ; then
  echo "Could not find semantic-release-cli in path, aborting"
  exit 1
fi

# TODO Check if directory is empty

REPO_NAME="${PWD##*/}"

git init

hub create $HUB_FLAGS $REPO_NAME

npm init --scope @eliasnorrby -y

echo "# $REPO_NAME" > README.md
echo "" >> README.md

~/scripts/generate-badges.sh >> README.md

semantic-release-cli setup

npm install

npx @eliasnorrby/semantic-release-config
npx @eliasnorrby/commitlint-config
npx @eliasnorrby/prettier-config

# travis --version
# ~/scripts/add-slack-notifications.sh

