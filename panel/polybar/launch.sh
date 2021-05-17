#!/usr/bin/env bash

killall -q polybar

#echo "---" | tee -a /tmp/polybar.log
#polybar mybar >> /tmp/polybar.log 2>&1 & disown

pm=$(polybar --list-monitors | grep '(primary)' | cut -d":" -f1)
MONITOR=$pm polybar --reload main &

for m in $(polybar --list-monitors | grep -v '(primary)' | cut -d":" -f1); do
  MONITOR=$m polybar --reload secondary &
done
