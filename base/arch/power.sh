#!/usr/bin/env bash

menu() {
  rofi -dmenu -i -width 10 -lines 3 -monitor primary -no-custom "$@"
}

confirm() {
  local response
  response=$(menu -p "Are you sure?" -u 0 <<<$'yes\nno')
  case $response in
    yes) return ;;
    *) return 1 ;;
  esac
}

ACTIONS=$'suspend\nreboot\nshutdown'

ACTION=$(menu -p "What to do?" -u 2 <<<"$ACTIONS")
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


