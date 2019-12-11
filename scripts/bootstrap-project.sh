#!/usr/bin/env bash

# Bootstrap a node project with my personal configurations for
# prettier, commitlint and semantic release.

DIR=$(dirname $([ -L "$0" ] && readlink -f "$0" || echo $0))
[ -f $DIR/echos.sh ] && . $DIR/echos.sh || (echo "Could not source 'echos', aborting" && exit 1)

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
  -r REPO     Specify name of remote repo (default: current directory)
  -p          Make the remote repository private
  -h          Show usage

Example:
  ${0##*/} -p

EOF

set -eo pipefail

REPO_NAME="${PWD##*/}"

while getopts r:ph opt; do
  case $opt in
    r) REPO_NAME=$OPTARG                        ;;
    p) HUB_FLAGS="-p"                           ;;
    h) echo "$USAGE" && exit 0                  ;;
    *) echo-fail "$ERROR" && exit 1             ;;
  esac
done

if ! command -v npm >/dev/null 2>&1 ; then
  echo-fail "Could not find npm in path, aborting"
  exit 1
fi

if ! command -v hub >/dev/null 2>&1 ; then
  echo-fail "Could not find hub in path, aborting"
  exit 1
fi

if ! command -v semantic-release-cli >/dev/null 2>&1 ; then
  echo-fail "Could not find semantic-release-cli in path, aborting"
  exit 1
fi

if [ ! $(ls -a1 | wc -l ) -eq 2 ] ; then
  echo-fail "Directory is not empty, aborting"
  exit 1
fi

echo-info "Initialize local repository"
git init

echo-info "Create remote repository on github"
hub create $HUB_FLAGS $REPO_NAME

echo-info "Run npm init"
npm init --scope @eliasnorrby -y

echo-info "Create README"
echo "# $REPO_NAME" > README.md
echo "" >> README.md

echo-info "Generate badges for README"
$DIR/generate-badges.sh >> README.md

echo-info "Run semantic-release-cli : provide your credentials"
semantic-release-cli setup

echo-info "Run npm install"
npm install

echo-info "Install tools"
echo-info "> semantic-release-config..."
npx @eliasnorrby/semantic-release-config
echo-info "> commitlint-config..."
npx @eliasnorrby/commitlint-config
echo-info "> prettier-config..."
npx @eliasnorrby/prettier-config

if ! command -v travis >/dev/null 2>&1 ; then
  echo-skip "Could not find travis cli in path, not writing notification settings"
  exit 0
fi

echo-info "Add slack build notifications"
$DIR/add-slack-notifications.sh

echo-info "Done!"
