#!/bin/sh
# Launch yazi picker with specified class and directory
# Usage: capture_picker <class> <directory>

CLASS="${1:-CapturePicker}"
DIR="${2:-$HOME}"

[ ! -d "$DIR" ] && mkdir -p "$DIR"

exec kitty --class "$CLASS" -e yazi "$DIR"
