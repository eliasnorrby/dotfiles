#!/bin/sh

BSPWMRC="${XDG_CONFIG_HOME}/bspwm/bspwmrc"

[ ! -f "$BSPWMRC" ] && exit 1

# From
#   WM_CLASS(STRING) = "google-chrome", "Google-chrome"
# get
#   Google-chrome
window_class() {
  xprop -id "$(xdo id)" | grep -oP '^WM_CLASS.*"\K[^"]+(?="$)'
}

# From
#   bspc rule -a Google-chrome desktop='2' follow=on
# get
#   2
desktop_for_class() {
  grep -oP "^bspc rule -a.*${1}.*desktop='\K[^']+(?=')" "$BSPWMRC"
}

send_to_desktop() {
  bspc node --to-desktop "${1}" --follow
}

notify() {
  notify-send -u low -t 2300 "$@"
}

class=$(window_class)
[ -z "$class" ] && notify "Could not determine WM_CLASS of current window" && exit 1

desktop=$(desktop_for_class "$class")
[ -z "$desktop" ] && notify "No rule found for window with class '$class'" && exit 1

send_to_desktop "$desktop"
