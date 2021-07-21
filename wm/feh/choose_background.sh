#!/bin/sh

WALLDIR="${HOME}/wallpapers"

[ ! -d "$WALLDIR" ] && exit 1

feh \
  --fullscreen \
  --auto-zoom \
  --action 'feh --bg-fill %F; xdotool key q' \
  "$WALLDIR"
