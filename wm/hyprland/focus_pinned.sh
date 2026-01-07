#!/bin/sh

# Focus the first pinned window, if any exists.

PINNED_ADDR=$(hyprctl clients -j | jq -r '.[] | select(.pinned == true) | .address' | head -1)

if [ -z "$PINNED_ADDR" ]; then
  echo "No pinned window found"
  exit 1
fi

hyprctl dispatch focuswindow "address:$PINNED_ADDR"
