#!/bin/sh

MAIN="${HOME}/wallpapers"
FALLBACK="${HOME}/.dotfiles/assets/wallpapers"

if [ -d "$MAIN" ]; then
  WALLDIR="$MAIN"
elif [ -d "$FALLBACK" ]; then
  WALLDIR="$FALLBACK"
else
  echo "No wallpapers found"
  exit 1
fi

WALL=$1

[ -f "$WALL" ] || WALL="$(find "$WALLDIR" -type f | sort -R | tail -1)"

[ -n "$WALL" ] && feh --no-fehbg --bg-fill "$WALL"
