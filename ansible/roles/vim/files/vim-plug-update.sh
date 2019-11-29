#!/usr/bin/env bash

UPDATE_LOG=$(vim +'PlugUpdate --sync' +qall 2>/dev/null)
grep -o "Press 'D' to see the updated changes" <<< "$UPDATE_LOG" > /dev/null

if [ "$?" -eq 0 ] ; then
  echo -n "changed"
else
  echo -n "unchanged"
fi
