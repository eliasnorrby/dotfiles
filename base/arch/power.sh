#!/usr/bin/env bash

menu() {
  rofi -dmenu \
    -i -no-custom \
    -font 'mononoki Nerd Font 20' \
    -width 10 -lines 4 -monitor primary "$@"
}

confirm() {
  local response
  response=$(menu -p "Are you sure?" -u 0 <<<$'yes\nno')
  case $response in
    yes) return ;;
    *) return 1 ;;
  esac
}

ACTIONS=$'  suspend\n  reboot\n  shutdown\n  reload'

ACTION=$(menu -p "POWER" -u 2 <<<"$ACTIONS")
ACTION=${ACTION##* }
[ -z "$ACTION" ] && exit

case $ACTION in
  suspend)
    echo "Suspending"
    systemctl suspend
    ;;
  reboot)
    if confirm; then
      echo "Rebooting"
      reboot
    fi
    ;;
  reload)
    echo "Reloading"
    notify-send -t 1000 "Reloading bspwm" || :
    bspc wm -r
    ;;
  shutdown)
    if confirm; then
      echo "Powering off"
      systemctl poweroff
    fi
    ;;
  *)
    echo "Unexpected action"
    exit 1
    ;;
esac


