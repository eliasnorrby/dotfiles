#!/bin/bash

declare -A ICONMAP
ICONMAP[A5]=

ICONMAP[1]=
ICONMAP[2]=
ICONMAP[3]=
ICONMAP[4]=

ICONMAP[B1]=
ICONMAP[B2]=
ICONMAP[B3]=
ICONMAP[B5]=

counter=0
bspc query -D --names | while read -r name; do
  icon=${ICONMAP[$name]}
  icon=${icon:-$name}
  printf 'ws-icon-%i = %s;'"$icon"'\n' $((counter++)) "$name"
done
