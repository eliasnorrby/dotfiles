#!/bin/sh
# Open a linear.app URL in the installed Linear PWA window (work profile).
#
# `--app-id` alone ignores any URL (it opens the app's home), and Chrome's
# link capturing on Linux only offers an "Open in app" chip in the browser.
# The switch made for jump-list shortcuts is the one path that launches a PWA
# at an in-scope URL: with the app already running, its window navigates
# there in place.
#
# The launch command (profile, app id) is read from the PWA's desktop entry,
# so nothing here names a Chrome profile or an app id.
url=$1
entry="${XDG_DATA_HOME:-$HOME/.local/share}/applications/linear.desktop"
launch=$(sed -n 's/^Exec=//p' "$entry" | head -1 | sed 's/ %[uUfF]$//')
class=$(sed -n 's/^StartupWMClass=//p' "$entry" | head -1)

# Without the PWA installed, the work browser is the next best thing.
[ -n "$launch" ] || exec chrome-work "$url"

eval "$launch --app-launch-url-for-shortcuts-menu-item=\"\$url\"" >/dev/null 2>&1 &
[ -n "$class" ] && hyprctl dispatch focuswindow "class:$class" >/dev/null 2>&1
