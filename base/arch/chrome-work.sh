#!/bin/sh

# Focus any existing window first: Chrome only reuses a window it believes is
# on the current workspace, otherwise it spawns a new one.
hyprctl dispatch focuswindow "class:ChromeWork" >/dev/null 2>&1

exec google-chrome-stable --class=ChromeWork --user-data-dir="$HOME/.config/google-chrome-work" "$@"
