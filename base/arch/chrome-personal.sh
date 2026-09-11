#!/bin/sh

# Focus any existing window first: Chrome only reuses a window it believes is
# on the current workspace, otherwise it spawns a new one.
hyprctl dispatch focuswindow "class:ChromePersonal" >/dev/null 2>&1

exec google-chrome-stable --class=ChromePersonal "$@"
