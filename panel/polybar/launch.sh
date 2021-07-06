#!/bin/sh

killall -q polybar

list_monitors() {
  polybar --list-monitors
}

monitor_name() {
  cut -d ":" -f 1
}

exclude_primary() {
  grep -v '(primary)'
}

exclude_rightmost() {
  if [ -n "$rightmost_monitor" ]; then
    grep -v "$rightmost_monitor"
  else
    cat
  fi
}

launch_bar_on_monitor() {
  MONITOR=$2 polybar --reload "$1" &
}

primary_monitor=$(list_monitors | grep '(primary)' | monitor_name)
launch_bar_on_monitor main "$primary_monitor"

rightmost_monitor=$(list_monitors | exclude_primary | tail -1 | monitor_name)
if [ -n "$rightmost_monitor" ]; then
  launch_bar_on_monitor secondary-stats "$rightmost_monitor"
fi

for monitor in $(list_monitors | exclude_primary | exclude_rightmost | monitor_name); do
  launch_bar_on_monitor secondary "$monitor"
done
