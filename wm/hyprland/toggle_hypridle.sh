#!/bin/sh

# Toggles hypridle (idle lock/dpms/suspend) on/off

if pgrep -x hypridle >/dev/null; then
  pkill -x hypridle
  notify-send "Hypridle" "Idle management stopped"
else
  hyprctl dispatch exec hypridle
  notify-send "Hypridle" "Idle management started"
fi
