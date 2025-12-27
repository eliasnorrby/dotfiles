#!/bin/sh

count=$(checkupdates 2>/dev/null | wc -l)

if [ "$count" -gt 0 ]; then
  echo " $count"
fi
