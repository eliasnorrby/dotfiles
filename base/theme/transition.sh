#!/usr/bin/env bash
# Switch themes behind a cover: grab the screen, lay the grab over
# everything, switch underneath, then fade the cover away. The apps still
# change one by one over half a second, but under the cover nobody sees
# it; what the eye gets is one cross-fade from the old desktop to the new.
#
#   theme_transition NAME        switch to NAME behind the cover
#   theme_transition             cycle to the next theme behind the cover
#
# Uses what the desktop has: grim for the grab, a kitty window showing it
# through the icat kitten as the cover, hyprland window rules to make the
# cover instant, fullscreen and opaque, and hyprland's animated window alpha
# to fade it. Proof of concept; falls back to a plain switch without a
# compositor.

set -euo pipefail

target="${1:-}"
cls=ThemeCover

if ! command -v hyprctl >/dev/null || ! command -v grim >/dev/null; then
  if [ -n "$target" ]; then exec theme set "$target"; else exec theme cycle; fi
fi

shot="$(mktemp --suffix=.png)"
cleanup() {
  rm -f "$shot"
}
trap cleanup EXIT

grim "$shot"

# The cover: appears without animation, covers bars too, never takes focus,
# and is drawn fully opaque whatever the inactive-window opacity says.
hyprctl keyword windowrule \
  "match:class $cls, float on, fullscreen on, pin on, noanim on, noblur on, noshadow on, noborder on, opaque on, noinitialfocus on" \
  >/dev/null

kitty --class "$cls" \
  -o background_opacity=1 -o window_padding_width=0 -o cursor_blink_interval=0 \
  -o confirm_os_window_close=0 -o background=#000000 \
  -e sh -c "printf '\033[?25l'; sleep 0.15; kitten icat --transfer-mode=file --scale-up --align=left '$shot'; sleep 30" \
  >/dev/null 2>&1 &

addr=""
for _ in $(seq 1 60); do
  addr="$(hyprctl clients -j | python3 -c '
import json, sys
print(next((c["address"] for c in json.load(sys.stdin) if c["class"] == "'"$cls"'"), ""))')"
  [ -n "$addr" ] && break
  sleep 0.05
done
if [ -z "$addr" ]; then
  echo "theme_transition: no cover window; switching plainly" >&2
  if [ -n "$target" ]; then theme set "$target"; else theme cycle; fi
  exit 0
fi
sleep 0.35 # let icat finish drawing before anything changes underneath

if [ -n "$target" ]; then theme set "$target"; else theme cycle; fi
sleep 0.4 # let the apps settle under the cover

# Fade: hyprland animates alpha with its `fade` curve. Re-enable animation
# on the cover first, since it was mapped with noanim.
hyprctl setprop "address:$addr" noanim 0 >/dev/null
hyprctl setprop "address:$addr" alpha 0 >/dev/null
sleep 0.45
hyprctl dispatch closewindow "address:$addr" >/dev/null
