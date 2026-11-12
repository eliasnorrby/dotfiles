#!/usr/bin/env bash
# Switch themes behind a cover: grab the screen, lay the grab over
# everything, switch underneath, then fade the cover away. The apps still
# change one by one over half a second, but under the cover nobody sees
# it; what the eye gets is one cross-fade from the old desktop to the new.
#
#   theme_transition NAME        switch to NAME behind the cover
#   theme_transition             cycle to the next theme behind the cover
#
# Uses what the desktop has: grim for the grab, mpv showing it as the cover
# (a bare fullscreen frame, no controls), hyprland window rules to make the
# cover instant and opaque, and hyprland's animated window opacity to fade
# it. Proof of concept; falls back to a plain switch without a compositor.

set -euo pipefail

target="${1:-}"
cls=ThemeCover

if ! command -v hyprctl >/dev/null || ! command -v grim >/dev/null || ! command -v mpv >/dev/null; then
  if [ -n "$target" ]; then exec theme set "$target"; else exec theme cycle; fi
fi

shot="$(mktemp --suffix=.png)"
cover_pid=""
cleanup() {
  [ -n "$cover_pid" ] && kill "$cover_pid" 2>/dev/null
  rm -f "$shot"
}
trap cleanup EXIT

grim "$shot"

# The cover's window rules live in hyprland's conf.d (theme.conf): a float
# at the origin, mapped without animation, drawn opaque, undecorated. They
# are in the config because the switch reloads hyprland, which drops
# runtime rules. Fullscreen (over the bar) only takes through the
# dispatcher on this hyprland, so the cover is focused for that and focus
# is handed back once it is gone.
mpv --no-config --really-quiet --no-audio --no-osc --no-input-default-bindings \
  --no-border --image-display-duration=inf --wayland-app-id="$cls" "$shot" \
  >/dev/null 2>&1 &
cover_pid=$!

prev="$(hyprctl activewindow -j | python3 -c 'import json, sys; print(json.load(sys.stdin).get("address", ""))')"
addr=""
for _ in $(seq 1 60); do
  addr="$(hyprctl clients -j | python3 -c '
import json, sys
print(next((c["address"] for c in json.load(sys.stdin) if c["class"] == "'"$cls"'"), ""))')"
  [ -n "$addr" ] && break
  sleep 0.02
done
if [ -z "$addr" ]; then
  echo "theme_transition: no cover window; switching plainly" >&2
  if [ -n "$target" ]; then theme set "$target"; else theme cycle; fi
  exit 0
fi
hyprctl dispatch focuswindow "address:$addr" >/dev/null
hyprctl dispatch fullscreen 0 >/dev/null
sleep 0.2 # the frame matches the grab from here on

if [ -n "$target" ]; then theme set "$target"; else theme cycle; fi
sleep 0.4 # let the apps settle under the cover

# Fade: hyprland animates the opacity property with its `fade` curve.
# Re-enable animation on the cover first, since it was mapped without.
hyprctl dispatch setprop "address:$addr" no_anim 0 >/dev/null
hyprctl dispatch setprop "address:$addr" opacity 0 >/dev/null
sleep 0.45
hyprctl dispatch closewindow "address:$addr" >/dev/null
[ -n "$prev" ] && hyprctl dispatch focuswindow "address:$prev" >/dev/null
