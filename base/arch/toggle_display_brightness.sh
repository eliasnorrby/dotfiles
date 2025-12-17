#!/bin/sh

# Toggles display brightness between two set values

HIGH=45
LOW=5

current=$(ddcutil getvcp 10 --display 1 -t | cut -d ' ' -f 4)

bus=$(ddcutil detect -t | grep -o '/dev/i2c-.*' | cut -d '-' -f 2)

if [ -z "$bus" ]; then
  echo "Could not determine display bus"
  exit 1
fi

new=$HIGH

if [ "$current" = "$HIGH" ]; then
  new=$LOW
fi

ddcutil setvcp 10 "$new" --bus "$bus"
