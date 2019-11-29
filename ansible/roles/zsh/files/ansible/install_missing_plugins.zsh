#!/usr/bin/env zsh

. ${ZPLUG_PLUGS}
if ! zplug check ; then
  echo -p "changed"
  zplug install > /dev/null 2>&1
else
  echo -p "unchanged"
fi
