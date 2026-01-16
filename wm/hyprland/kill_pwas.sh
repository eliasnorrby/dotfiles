#!/bin/sh
# Close Chrome PWA windows before suspend to prevent post-resume CPU spikes

# Chrome PWAs have window class pattern: chrome-{id}-Default
hyprctl clients -j |
  jq -r '.[] | select(.class | startswith("chrome-")) | .address' |
  while read -r addr; do
    hyprctl dispatch closewindow "address:$addr"
  done
