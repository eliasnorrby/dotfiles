#!/bin/sh

input=$(rofi -dmenu -i -l 0 -p "task" </dev/null)

[ -z "$input" ] && exit 0

# shellcheck disable=SC2086
# Intentional word-splitting: taskwarrior parses proj:foo, +tag, etc.
# from separate argv tokens, not from a single quoted description.
if output=$(task rc.context= rc.verbose=new-id add $input 2>&1); then
  notify-send -a "task" "Task added" "$output"
else
  notify-send -u critical -a "task" "Add failed" "$output"
fi
