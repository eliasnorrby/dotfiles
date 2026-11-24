#!/usr/bin/env bash
# kbptr: point and click from the keyboard, with wl-kbptr.
#
#   kbptr [window]       label the click targets detected in the focused
#                        window; typing one clicks it
#   kbptr screen         the same, on the whole screen
#   kbptr grid           a grid, for what detection misses: pick a tile, then
#                        bisect it; g/h/b click left/right/middle
#   kbptr loop [MODE]    MODE (window by default) again after every click,
#                        until Escape; for a series of clicks
#   kbptr kill           end whatever is open, a loop included
#
# Only one runs at a time: a second overlay, started while the first holds
# the keyboard, never gets it and can't be dismissed. A start while one is
# open does nothing. Colours come from base/theme, which links the config.
#
# KBPTR_LOOP_DELAY: seconds between a click and the next overlay, for the
# clicked app to redraw before the targets are detected again (0.4).

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

kbptr_args() {
  local detect=(-o "modes=floating,click" -o mode_floating.source=detect)
  case "$1" in
    screen) args=("${detect[@]}") ;;
    window)
      args=("${detect[@]}")
      local area
      area=$(focused_window)
      if [[ -n $area ]]; then
        args+=(--restrict "$area")
      fi
      ;;
    grid) args=(-o "modes=tile,bisect") ;;
    *) usage ;;
  esac
  args+=(-o "cancellation_status_code=$cancelled")
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

kill_running() {
  exec 9>>"$lock"
  if flock -n 9; then
    exit 0
  fi
  # The loop first, so it can't start another overlay, then the overlay
  kill "$(<"$lock")" 2>/dev/null || true
  pkill -x wl-kbptr || true
}

main() {
  local cmd=${1:-window}
  case "$cmd" in
    screen | window | grid)
      take_lock
      kbptr_args "$cmd"
      exec wl-kbptr "${args[@]}"
      ;;
    loop)
      take_lock
      loop "${2:-window}"
      ;;
    kill) kill_running ;;
    *) usage ;;
  esac
}

main "$@"
