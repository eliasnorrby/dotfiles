#!/usr/bin/env bash

STATUS_LOG=$(vim +PlugStatus +qall 2>/dev/null)
grep -o "Not found. Try" <<< "$STATUS_LOG" > /dev/null

if [ "$?" -eq 0 ] ; then
  vim +'PlugInstall --sync' +qall > /dev/null
  echo -n "changed"
else
  echo -n "unchanged"
fi
