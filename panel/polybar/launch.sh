#!/usr/bin/env bash

killall -q polybar

#echo "---" | tee -a /tmp/polybar.log
#polybar mybar >> /tmp/polybar.log 2>&1 & disown

for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar --reload mybar &
done
