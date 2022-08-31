#!/usr/bin/env bash

GIT_LOG_FORMAT='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar)%Creset'

if ! command -v watch >/dev/null 2>&1; then
  echo "Must have 'watch' command installed"
  exit 1
fi

watch -c -n 2 \
  'git --no-pager log \
    --color \
    --graph \
    --pretty=format:'"'$GIT_LOG_FORMAT'"' \
    --abbrev-commit \
    --branches \
    -10'
