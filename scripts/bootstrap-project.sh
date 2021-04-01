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
  -f          Run even if current directory is not empty
  -h          Show usage

Example:
  ${0##*/} -p

EOF

set -eo pipefail

REPO_NAME="${PWD##*/}"

if [ "$1" = "--help" ]; then
  echo "$USAGE" && exit 0
fi

while getopts r:pfh opt; do
  case $opt in
    r) REPO_NAME=$OPTARG                        ;;
    p) HUB_FLAGS="-p"                           ;;
    f) OPT_CHECK_EMPTY="false"                ;;
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

if [[ "$OPT_CHECK_EMPTY" != false ]] && [ ! $(ls -a1 | wc -l ) -eq 2 ] ; then
  echo-fail "Directory is not empty, aborting"
  exit 1
fi

# End of checks

if [ ! -d .git ] ; then
  echo-info "Initialize local repository"
  git init
else
  echo-skip "Local repository already set up"
fi

if [ -z "$(git remote)" ] ; then
  echo-info "Create remote repository on github"
  hub create $HUB_FLAGS $REPO_NAME
else
  echo-skip "Remote repository already set up"
fi

if [ ! -f package.json ] ; then
  echo-info "Run npm init"
  npm init --scope @eliasnorrby -y
else
  echo-skip "package.json already set up"
fi

if [ ! -f README.md ] ; then
  echo-info "Create README"
  echo "# $REPO_NAME" > README.md
  echo "" >> README.md

  echo-info "Generate badges for README"
  $DIR/generate-badges.sh >> README.md
else
  echo-skip "README.md already set up"
fi

echo-info "Run semantic-release-cli : provide your credentials"
semantic-release-cli setup

echo-info "Run npm install"
npm install

echo-info "Install tools"
echo-info "> semantic-release-config..."
npx @eliasnorrby/semantic-release-config
echo-ok "> semantic-release-config installed"
echo-info "> commitlint-config..."
npx @eliasnorrby/commitlint-config
echo-ok "> commitlint-config installed"
echo-info "> prettier-config..."
npx @eliasnorrby/prettier-config
echo-ok "> prettier-config installed"
echo-info "> git-config..."
npx @eliasnorrby/git-config
echo-ok "> git-config installed"
echo-info "> dependabot-config..."
npx @eliasnorrby/dependabot-config
echo-ok "> dependabot-config installed"

if ! command -v travis >/dev/null 2>&1 ; then
  echo-skip "Could not find travis cli in path, not writing notification settings"
  exit 0
fi

echo-info "Add slack build notifications"
$DIR/add-slack-notifications.sh

if [ -e LICENSE ] ; then
  echo-skip "LICENSE exists, not writing"
fi

echo-info "Writing LICENSE"
cat <<EOF >> LICENSE
The MIT License (MIT)

Copyright (c) 2019 Elias Norrby.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

EOF

echo-info "Done!"
