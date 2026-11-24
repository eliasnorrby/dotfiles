#!/usr/bin/env bash
# kbptr: point and click from the keyboard, with wl-kbptr.
#
#   kbptr [window]       label the click targets detected in the focused
#                        window; typing one clicks it
#   kbptr screen         the same, on the whole screen
#   kbptr double         the same, with a double click (a word)
#   kbptr triple         the same, with a triple click (a line)
#   kbptr grid           a grid, for what detection misses: pick a tile, then
#                        bisect it; g/h/b click left/right/middle
#   kbptr point          a grid over the whole screen; picking a tile only
#                        moves the pointer there, e.g. over a pane to scroll
#   kbptr select         two detected targets in the focused window: drag
#                        from the left edge of the first to the right edge
#                        of the second, e.g. to select text (wl-kbptr's
#                        --drag, unreleased in 0.4.1)
#   kbptr loop [MODE]    MODE (window by default) again after every click,
#                        until Escape; for a series of clicks
#   kbptr toggle [MODE]  start the loop, or end whatever is open
#   kbptr kill           end whatever is open, a loop included
#
# Only one runs at a time: a second overlay, started while the first holds
# the keyboard, never gets it and can't be dismissed. A start while one is
# open does nothing. Colours come from base/theme, which links the config.
#
# KBPTR_LOOP_DELAY: seconds between a click and the next overlay, for the
# clicked app to redraw before the targets are detected again (0.4).
#
# wl-kbptr only clicks once, so double and triple move the pointer with
# it and click with ydotool (which keyd grabs and passes on).

set -euo pipefail

lock="${XDG_RUNTIME_DIR:-/tmp}/kbptr.lock"
# wl-kbptr's exit status on Escape (0 by default, the same as a click)
cancelled=10

usage() {
  sed -n '2,/^$/s/^# \{0,1\}//p' "$0" >&2
  exit 2
}

# Holds the lock for as long as this process (or what it execs) lives, and
# leaves its pid for `kbptr kill`. Exits quietly when one is already open.
take_lock() {
  exec 9>>"$lock"
  flock -n 9 || exit 0
  echo $$ >"$lock"
}

# The focused window as wl-kbptr's wxh+x+y. Nothing on an empty workspace,
# or when hyprctl can't say: then the whole screen.
focused_window() {
  local filter='select(.size) | "\(.size[0])x\(.size[1])+\(.at[0])+\(.at[1])"'
  hyprctl activewindow -j 2>/dev/null | jq -r "$filter" 2>/dev/null || true
}

# Detected targets in the focused window (the whole screen when there is
# none), then the given modes
in_window() {
  local area
  args=(-o "modes=$1" -o mode_floating.source=detect)
  area=$(focused_window)
  if [[ -n $area ]]; then
    args+=(--restrict "$area")
  fi
}

kbptr_args() {
  case "$1" in
    screen) args=(-o "modes=floating,click" -o mode_floating.source=detect) ;;
    window) in_window floating,click ;;
    # Only moves the pointer: multi_click does the clicking
    double | triple) in_window floating ;;
    grid) args=(-o "modes=tile,bisect") ;;
    # Without the click mode, the pick only moves the pointer
    point) args=(-o "modes=tile") ;;
    # --drag presses and releases the button itself: no click mode
    select)
      in_window floating
      args=(--drag "${args[@]}")
      ;;
    *) usage ;;
  esac
  args+=(-o "cancellation_status_code=$cancelled")
}

# Moves the pointer onto a target, then clicks there N times in quick
# succession (a click is 0xC0: left button down and up)
multi_click() {
  local status=0
  kbptr_args "$1"
  wl-kbptr "${args[@]}" || status=$?
  case $status in
    0) ydotool click --repeat "$2" --next-delay 20 0xC0 >/dev/null ;;
    "$cancelled") exit 0 ;;
    *) exit "$status" ;;
  esac
}

loop() {
  local mode=${1:-window} status
  while true; do
    kbptr_args "$mode"
    status=0
    wl-kbptr "${args[@]}" || status=$?
    case $status in
      0) sleep "${KBPTR_LOOP_DELAY:-0.4}" ;;
      "$cancelled") exit 0 ;;
      *) exit "$status" ;; # failed, or killed by `kbptr kill`
    esac
  done
}

# Ends what holds the lock: the loop first, so it can't start another
# overlay, then the overlay
stop() {
  kill "$(<"$lock")" 2>/dev/null || true
  pkill -x wl-kbptr || true
}

kill_running() {
  exec 9>>"$lock"
  if ! flock -n 9; then
    stop
  fi
}

toggle() {
  exec 9>>"$lock"
  if flock -n 9; then
    echo $$ >"$lock"
    loop "${1:-window}"
  else
    stop
  fi
}

main() {
  local cmd=${1:-window}
  case "$cmd" in
    screen | window | grid | point | select)
      take_lock
      kbptr_args "$cmd"
      exec wl-kbptr "${args[@]}"
      ;;
    loop)
      take_lock
      loop "${2:-window}"
      ;;
    double)
      take_lock
      multi_click double 2
      ;;
    triple)
      take_lock
      multi_click triple 3
      ;;
    toggle) toggle "${2:-window}" ;;
    kill) kill_running ;;
    *) usage ;;
  esac
}

main "$@"
