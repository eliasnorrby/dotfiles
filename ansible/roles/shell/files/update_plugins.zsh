#!/usr/bin/env zsh

. ${ZPLUG_PLUGS}
zplug status | grep -m 1 "Local out of date" > /dev/null 2>&1
if [ "$?" -eq 0 ] ; then
  echo "changed"
  zplug update > /dev/null 2>&1
else
  echo "unchanged"
fi
