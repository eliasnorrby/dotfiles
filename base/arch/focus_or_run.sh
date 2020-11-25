#!/bin/sh

# Usage: focus_or_run program [class]

# Will search windows based on 'class' (defaults to 'program').
# If a window is found, it is focused, otherwise the program is
# executed.

_is_callable()  {
  command -v "$1" >/dev/null || return 1
}

_focus_or_run()  {
  CLASS=${2:-$1}
  PROGRAM=$1

  WINDOWS=$(xdotool search --class "$CLASS")

  if [ -n "$WINDOWS" ]; then
    RESULT=$(xdotool windowactivate "$WINDOWS" 2>&1 >/dev/null)
    if echo "$RESULT" | grep failed >/dev/null; then
      _try_harder "$WINDOWS"
    fi
  elif _is_callable "$PROGRAM"; then
    exec "$PROGRAM"
  else
    echo "Could not focus or run: $PROGRAM"
  fi
}

# There will be multiple matches for some calls, e.g:
#   xdotool search --class chromium
# Only one ID will work for focusing - the one corresponding
# to the window with _NET_WM_DESKTOP specified. We need to find
# the appropriate ID and pass it to xdotool windowactivate.

# xprop is used to fetch the property for each window id.
# The result is either
#   _NET_WM_DESKTOP: not found.
# or
#   _NET_WM_DESKTOP(CARDINAL) = <number>

# We grep this string for '=' to find our ID.
_try_harder() {
  while read -r wid; do
    if _specifies_desktop "$wid"; then
      xdotool windowactivate "$wid"
      exit
    fi
  done <<EOF
$1
EOF
}

_specifies_desktop()  {
  xprop -id "$1" _NET_WM_DESKTOP | grep '=' >/dev/null
}

_focus_or_run "$@"
