#!/usr/bin/env bash
# Run by hypridle after resume. Video memory comes back from suspend with a
# few bit flips in buffers that lived through it, which shows as speckles
# on anything uploaded once and kept: the wallpaper first of all. Re-upload
# it by restarting hyprpaper. Its IPC rejects reload requests on the
# installed version, so a restart is the only way.

hyprctl dispatch dpms on >/dev/null

if pgrep -x hyprpaper >/dev/null; then
  pkill -x hyprpaper
  sleep 0.5
fi
hyprctl dispatch exec hyprpaper >/dev/null
