#!/bin/sh

# Reload Hyprland and related services

hyprctl reload

if command -v makoctl >/dev/null 2>&1; then
  makoctl reload
fi
if command -v swaync-client >/dev/null 2>&1; then
  swaync-client --reload-config
  swaync-client --reload-css
fi
pkill -USR2 waybar

notify-send "Hyprland Reloaded" "Hyprland and related services have been reloaded."
