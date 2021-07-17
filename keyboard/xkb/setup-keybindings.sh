#!/bin/sh

# Custom layouts defined in xkb/custom
# - qwerty with hyper key
# - workman-p with hyper key and default caps lock behaviour
# Options in xkb/layout.xkb
# - 'altwin:swap_lalt_lwin': Swap left alt and left super (to mimic Apple keyboard layouts)
# - 'grp:shifts_toggle': Change layouts with double-shift
# - 'ctrl:nocaps': Caps lock is Control
xkbcomp -I"${XDG_CONFIG_HOME}/xkb" "${XDG_CONFIG_HOME}/xkb/layout.xkb" "${DISPLAY}"

# Map right alt to hyper
xmodmap -e "keycode 108 = Hyper_L Hyper_L Hyper_L Hyper_L"

# Tapping Control is Escape
killall -q xcape
xcape
