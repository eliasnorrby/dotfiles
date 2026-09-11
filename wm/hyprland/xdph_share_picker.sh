#!/bin/sh
# Custom screencopy picker for xdg-desktop-portal-hyprland: answers the
# portal's share request with the focused monitor immediately, so no
# picker dialog is ever shown.
#
# To share a window or region instead, run `xdph_share_picker manual`
# before starting the share; the next request gets the stock picker.

flag="${XDG_CACHE_HOME:-$HOME/.cache}/xdph-manual-picker"

if [ "$1" = "manual" ]; then
  touch "$flag"
  echo "Next share request will show the stock picker."
  exit 0
fi

if [ -e "$flag" ]; then
  rm -f "$flag"
  exec hyprland-share-picker "$@"
fi

focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

if [ -z "$focused" ]; then
  exec hyprland-share-picker "$@"
fi

printf '[SELECTION]r/screen:%s\n' "$focused"
