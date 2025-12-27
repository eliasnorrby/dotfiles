#!/usr/bin/env bash

VARS=(
  # display
  WAYLAND_DISPLAY
  DISPLAY
  # xdg
  USERNAME
  XDG_BACKEND
  XDG_CURRENT_DESKTOP
  XDG_SESSION_TYPE
  XDG_SESSION_ID
  XDG_SESSION_CLASS
  XDG_SESSION_DESKTOP
  XDG_SEAT
  XDG_VTNR
  # hyprland
  HYPRLAND_CMD
  HYPRLAND_INSTANCE_SIGNATURE
  # misc
  XCURSOR_SIZE
  # ssh
  SSH_AUTH_SOCK
)

for v in "${VARS[@]}"; do
  if [[ -n ${!v} ]]; then
    tmux setenv -g "$v" "${!v}"
  fi
done
