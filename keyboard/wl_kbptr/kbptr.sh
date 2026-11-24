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
#   kbptr shot           a screenshot between two corners in the focused
#                        window (either order), saved and copied; each is a
#                        grid tile, split down with the arrows and taken
#                        with Enter or Space: the crosshair (the centre)
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
#
# Screenshots go to KBPTR_SHOT_DIR (~/Pictures/Screenshots) and the
# clipboard, KBPTR_SHOT_DELAY seconds (0.2) after the last pick, so that
# the overlay is gone from the screen.

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
    # Only prints the pick (with -p): shot takes the screenshot
    shot)
      in_window tile,split
      args=(--only-print "${args[@]}")
      ;;
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

# Picks an area (a tile split down, taken with Enter or Space) and sets
# x y w h to it on the desktop. Returns 1 when cancelled.
pick_area() {
  local out status=0 re
  kbptr_args shot
  out=$(wl-kbptr "${args[@]}") || status=$?
  case $status in
    0) ;;
    "$cancelled") return 1 ;;
    *) exit "$status" ;;
  esac
  # wxh+x+y within the output, then the output's own +x+y
  re='^([0-9]+)x([0-9]+)\+(-?[0-9]+)\+(-?[0-9]+) \+(-?[0-9]+)\+(-?[0-9]+)'
  if [[ ! $out =~ $re ]]; then
    echo "kbptr: can't read wl-kbptr's pick: $out" >&2
    exit 1
  fi
  w=${BASH_REMATCH[1]} h=${BASH_REMATCH[2]}
  x=$((BASH_REMATCH[3] + BASH_REMATCH[5]))
  y=$((BASH_REMATCH[4] + BASH_REMATCH[6]))
}

# A screenshot between two picked points: the centre of each picked area,
# where split mode draws its crosshair
shot() {
  local x y w h x1 y1 x2 y2 dir file
  pick_area || exit 0
  x1=$((x + w / 2)) y1=$((y + h / 2))
  pick_area || exit 0
  x2=$((x + w / 2)) y2=$((y + h / 2))
  if ((x2 < x1)); then
    x=$x1 x1=$x2 x2=$x
  fi
  if ((y2 < y1)); then
    y=$y1 y1=$y2 y2=$y
  fi
  if ((x2 == x1 || y2 == y1)); then
    echo "kbptr: the two corners make no area" >&2
    exit 1
  fi

  # No overlay is open any more. Release the lock before wl-copy, which
  # stays in the background serving the clipboard, can inherit it.
  exec 9>&-
  sleep "${KBPTR_SHOT_DELAY:-0.2}"
  dir=${KBPTR_SHOT_DIR:-$HOME/Pictures/Screenshots}
  mkdir -p "$dir"
  file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
  grim -g "$x1,$y1 $((x2 - x1))x$((y2 - y1))" - | tee "$file" | wl-copy
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
    shot)
      take_lock
      shot
      ;;
    toggle) toggle "${2:-window}" ;;
    kill) kill_running ;;
    *) usage ;;
  esac
}

main "$@"
