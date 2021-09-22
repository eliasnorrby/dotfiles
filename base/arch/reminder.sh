#!/usr/bin/env bash

menu() {
  rofi -dmenu \
    -font 'mononoki Nerd Font 20' \
    -theme-str 'window {width: 40%;} listview {lines: 0; scrollbar: false;}' \
    -monitor primary "$@"
}

sleep_error() {
  notify-send -u critical -t 2000 "Error" "Invalid duration: $DURATION"
}

REMINDER=$(echo "" | menu -p "Remind me to")
[ -z "$REMINDER" ] && exit
DURATION=$(menu -p "Remind me in")
[ -z "$DURATION" ] && exit

sleep "$DURATION" || { sleep_error && exit 1; }

notify-send -t 5000 Reminder "$REMINDER"
