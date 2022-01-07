#!/bin/bash

DEFAULT_ICON=•

declare -A ICONMAP
ICONMAP[A1]=
ICONMAP[A2]=
ICONMAP[A3]=
ICONMAP[A4]=

ICONMAP[1]=
ICONMAP[2]=
ICONMAP[3]=
ICONMAP[4]=

ICONMAP[B1]=
ICONMAP[B2]=
ICONMAP[B3]=
ICONMAP[B4]=

counter=0
bspc query -D --names | while read -r name; do
  icon=${ICONMAP[$name]}
  icon=${icon:-$DEFAULT_ICON}
  printf 'ws-icon-%i = %s;'"$icon"'\n' $((counter++)) "$name"
done
