#!/usr/bin/env zsh

. ${ZPLUG_PLUGS}
if ! zplug check ; then
  echo "changed"
  zplug install > /dev/null 2>&1
else
  echo "unchanged"
fi
