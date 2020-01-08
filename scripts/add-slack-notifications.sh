#!/usr/bin/env bash

# Set up slack notifications for Travis CI builds
#
# Run this script in a repository containing a travis.yml config file.
# The script will authenticate (travis login) and add an encrypted
# string to travis.yml containing the notifcation configuration.
#
# You need to set up a slack access token with your slack workspace.
# Put this in a file in the default location or reference it with the
# -f flag.

DIR=$(dirname $([ -L "$0" ] && readlink -f "$0" || echo $0))
[ -f $DIR/echos.sh ] && . $DIR/echos.sh || (echo "Could not source 'echos', aborting" && exit 1)

TOKEN_FILE_PATH="$HOME/.travis/slack-token"
ACCOUNT="eliasnorrby-dev"
CHANNEL="cicd"

ERROR="Bad usage, see $0 -h"

read -r -d "" USAGE <<EOF
Set up slack notifications for Travis CI builds

Usage: ${0##*/} [-facdh]
  -f PATH     Specify a token file to use
  -a ACCOUNT  Specify which workspace to send notifications to
  -c CHANNEL  Specify which channel to send notifications to
  -d          Do a dry run (show command to be executed)
  -h          Show usage

Example:
  ${0##*/} -a my-account -c dev

EOF

set -eo pipefail

while getopts f:a:c:dh opt; do
  case $opt in
    f) TOKEN_FILE_PATH=$OPTARG             ;;
    a) ACCOUNT=$OPTARG                     ;;
    c) CHANNEL=$OPTARG                     ;;
    d) OPT_DRY_RUN=true                    ;;
    h) echo "$USAGE" && exit 0             ;;
    *) echo-error "$ERROR" && exit 1       ;;
  esac
done

if [ ! -f .travis.yml ] ; then
  echo-fail "No travis.yml found in the current directory, aborting"
  exit 1
fi

if ! command -v travis >/dev/null 2>&1 ; then
  echo-fail "Could not find travis cli in path, aborting"
  exit 1
fi

TOKEN=$(cat $TOKEN_FILE_PATH)

VALUE=${ACCOUNT}:${TOKEN}
FIELD=notifications.slack
if [ ! -z "$CHANNEL" ] ; then
  VALUE=${VALUE}#${CHANNEL}
  FIELD=${FIELD}.rooms
fi


if [ "$OPT_DRY_RUN" == true ] ; then
  echo-info "Resulting command: travis encrypt --pro $VALUE --add $FIELD"
else
  if grep "^notifications" .travis.yml > /dev/null 2>&1 ; then
    echo-fail ".travis.yml already has a 'notifications' field."
    echo-fail "You should comment or remove it."
    exit 1
  fi

  TMPFILE=$(mktemp)
  cp .travis.yml $TMPFILE
  
  echo-info "Logging in to travis..."
  travis login --pro --auto
  echo-info "Encrypting value..."
  travis encrypt --pro "$VALUE" --add "$FIELD"

  LINE_NR=$(grep "^notifications" .travis.yml -n | cut -d ":" -f1)

  NOTIFICATION_LINES=$(sed -n "$LINE_NR,\$p" .travis.yml)
  mv $TMPFILE .travis.yml
  echo-info "Adding template settings"
  cat << EOF >> .travis.yml

$NOTIFICATION_LINES
    template:
      - "Build <%{build_url}|%{result}> for %{repository_slug}@%{branch} (<%{compare_url}|%{commit}>) in %{duration}"
    on_success: change
    on_failure: always
EOF
  echo-info "Done!"
fi

# template:
#   - "Build <%{build_url}|%{result}> for %{repository_slug}@%{branch} (<%{compare_url}|%{commit}>)"
# on_success: change
# on_failure: always
