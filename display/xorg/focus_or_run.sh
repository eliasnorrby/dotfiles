#!/bin/sh

# Usage: focus_or_run [class] program

# Will search windows based on 'class' (defaults to 'program').
# If a window is found, it is focused, otherwise the program is
# executed.

_is_callable()  {
  command -v "$1" >/dev/null || return 1
}

_focus_or_run()  {
  PROGRAM=${2:-$1}
  CLASS=$1

  if _focus "$CLASS"; then
    exit
  fi

  if [ -n "$3" ]; then
    HAS_ARGS=true
  fi

  if _is_callable "$PROGRAM"; then
    if [ "$HAS_ARGS" = "true" ]; then
      shift 2
      exec "$PROGRAM" "$@"
    else
      exec "$PROGRAM"
    fi
  else
    echo "Could not focus or run: $PROGRAM"
  fi
}

_focus() {
  WINDOWS=$(xdotool search --class "$1")

  for wid in $WINDOWS; do
    if _specifies_desktop "$wid"; then
      xdotool windowactivate "$wid"
      if _is_withdrawn "$wid"; then
        return 1
      fi
      return
    fi
  done
  return 1
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
_specifies_desktop()  {
  xprop -id "$1" _NET_WM_DESKTOP | grep '=' >/dev/null
}

_is_withdrawn() {
  xprop -id "$1" WM_STATE | grep 'window state: Withdrawn' >/dev/null
}

_focus_or_run "$@"
