#!/bin/sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 DESKTOP PROGRAM"
  exit 1
fi

_is_callable()  {
  command -v "$1" >/dev/null || return 1
}

DESKTOP=$1
PROGRAM=$2
bspc desktop --focus "$DESKTOP"
if _is_callable "$PROGRAM"; then
  exec "$PROGRAM"
else
  echo "Could not focus or run: $PROGRAM"
fi

