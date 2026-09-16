#!/bin/sh

# switch_layout.sh - Switch the keyboard layout everywhere it matters
#
# Two consumers have to agree on the layout: hyprland, and espanso, whose
# Wayland backend keeps its own xkb state per input device and can't ask
# the compositor. Espanso follows a key: with the elias:groups xkb option
# (keyboard/xkb) in its config, F14.. lock its layout 1.. by index, and the
# key reaches it through keyd's virtual keyboard.
#
# Hyprland can't use the same trick. Whenever it hands the focused window
# another keyboard (espanso's, after every expansion) it re-sends the
# keymap but not the group, so the window's fresh xkb state sits at group
# 0 until the next modifier press. So hyprland gets no groups at all:
# input:kb_layout in the config lists the choices, and this narrows it to
# the single active layout, which is then group 0 everywhere.
#
# Usage: switch_layout [next|sync|<index>]   (default: next)
#
# `sync` re-applies the stored index; hyprland runs it on every reload,
# which resets kb_layout to the full list. State lives in $XDG_RUNTIME_DIR
# so every login starts at index 0, matching fresh xkb states.

set -eu

run_dir="${XDG_RUNTIME_DIR:-/tmp}"
state_file="$run_dir/kb_layout_index"
menu_file="$run_dir/kb_layout_menu"

# KEY_F14 in linux/input-event-codes.h; F14..F17 are consecutive
first_key=184

option() {
  hyprctl getoption "input:$1" -j | jq -r '.str'
}

# The full list is only visible before we narrow it, i.e. right after a
# start or reload; remember it then.
layouts=$(option kb_layout)
case "$layouts" in
  *,*)
    printf '%s\n%s\n' "$layouts" "$(option kb_variant)" >"$menu_file"
    ;;
esac

if [ ! -r "$menu_file" ]; then
  echo "switch_layout: input:kb_layout lists fewer than two layouts" >&2
  exit 1
fi

layouts=$(sed -n 1p "$menu_file")
variants=$(sed -n 2p "$menu_file")

count=$(printf '%s\n' "$layouts" | tr ',' '\n' | wc -l)
[ "$count" -le 4 ] || count=4

current=0
if [ -r "$state_file" ]; then
  current=$(cat "$state_file")
fi
case "$current" in
  '' | *[!0-9]*) current=0 ;;
esac
[ "$current" -lt "$count" ] || current=0

case "${1:-next}" in
  next) index=$(((current + 1) % count)) ;;
  sync) index=$current ;;
  '' | *[!0-9]*)
    echo "usage: switch_layout [next|sync|<index>]" >&2
    exit 2
    ;;
  *)
    index=$1
    if [ "$index" -ge "$count" ]; then
      echo "switch_layout: index $index out of range for '$layouts'" >&2
      exit 2
    fi
    ;;
esac

layout=$(printf '%s' "$layouts" | cut -d, -f$((index + 1)))
variant=$(printf '%s' "$variants" | cut -d, -f$((index + 1)))

printf '%s\n' "$index" >"$state_file"

hyprctl keyword input:kb_variant "$variant" >/dev/null
hyprctl keyword input:kb_layout "$layout" >/dev/null

key=$((first_key + index))
ydotool key "$key:1" "$key:0"
