#!/usr/bin/env bash

echo -e "\a"

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "Claude" -message "Claude has finished processing your request."
fi

if command -v afplay >/dev/null 2>&1; then
  afplay -v 3 /System/Library/Sounds/Funk.aiff
fi
