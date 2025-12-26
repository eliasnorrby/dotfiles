#!/bin/sh

# Reload Hyprland and related services

hyprctl reload
makoctl reload
pkill -USR2 waybar

notify-send "Hyprland Reloaded" "Hyprland and related services have been reloaded."
