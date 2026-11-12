#!/bin/sh
# Pending pacman updates, for waybar. `checkupdates` syncs a database copy
# and takes seconds, which left the module blank after every waybar reload;
# the count is cached under $XDG_RUNTIME_DIR and served from there while it
# is younger than the module's interval, so a reload answers at once.

cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-updates"
max_age=1500

if [ -f "$cache" ]; then
  age=$(($(date +%s) - $(stat -c %Y "$cache")))
  if [ "$age" -lt "$max_age" ]; then
    cat "$cache"
    exit 0
  fi
fi

count=$(checkupdates 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo " $count" >"$cache"
else
  : >"$cache"
fi
cat "$cache"
