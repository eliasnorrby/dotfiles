#!/bin/sh
# Launch yazi picker with specified class and directory
# Usage: capture_picker <class> <directory>

CLASS="${1:-CapturePicker}"
DIR="${2:-$HOME}"

[ ! -d "$DIR" ] && mkdir -p "$DIR"

export YAZI_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/yazi-picker"
exec kitty --class "$CLASS" -o background_opacity=0.65 -e yazi "$DIR"
