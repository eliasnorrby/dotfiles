#!/bin/sh

awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' \
    "${XDG_CONFIG_HOME}/sxhkd/sxhkdrc"\
    | column -t -s '	' \
    | rofi -dmenu -p "Key bindings" -l 25 -i
