#!/bin/sh

# Usage: focus_or_run program [class]

_is_callable () {
  command -v "$1" >/dev/null || return 1
}

CLASS=${2:-$1}
PROGRAM=$1

WINDOW=$(xdotool search --class --limit 1 "$CLASS")

if [ -n "$WINDOW" ] ; then
  xdotool windowactivate "$WINDOW"
elif _is_callable "$PROGRAM" ; then
  exec "$PROGRAM"
else
  echo "Could not focus or run: $PROGRAM"
fi
