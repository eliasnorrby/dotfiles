#!/bin/sh

WALLDIR="${HOME}/wallpapers"

[ ! -d "$WALLDIR" ] && exit 1

background=$(find "$WALLDIR" -type f | fzf --preview 'feh --no-fehbg --bg-fill {}')

if [ -z "$background" ]; then
  [ -x ~/.fehbg ] && ~/.fehbg
else
  feh --bg-fill "$background"
fi
