#!/bin/sh

# Reload Hyprland and related services

hyprctl reload
makoctl reload

notify-send "Hyprland Reloaded" "Hyprland and related services have been reloaded."
