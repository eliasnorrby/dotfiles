#!/bin/sh
# Print the clipboard you are actually looking at.
#
# Reading is not the mirror image of writing. OSC 52 can push a copy out to the
# attached terminal, but pulling one back needs a query the terminal answers as
# input, and mosh carries only the write form, so there is no way to read the
# clipboard of a remote terminal in band. A read therefore comes from this
# machine's own clipboard, falling back to the newest tmux buffer, which is
# where a copy lands when no compositor is reachable.
set -u

# Point wl-clipboard at the running compositor; see copy_cmd for why a pane may
# arrive here with no Wayland environment of its own.
find_wayland() {
  [ -n "${WAYLAND_DISPLAY:-}" ] && return 0
  runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  [ -d "$runtime" ] || return 1
  for sock in "$runtime"/wayland-[0-9]*; do
    [ -S "$sock" ] || continue
    XDG_RUNTIME_DIR=$runtime
    WAYLAND_DISPLAY=${sock##*/}
    export XDG_RUNTIME_DIR WAYLAND_DISPLAY
    return 0
  done
  return 1
}

if command -v pbpaste >/dev/null 2>&1; then
  pbpaste
  exit
fi

if command -v wl-paste >/dev/null 2>&1 && find_wayland; then
  text=$(wl-paste -n 2>/dev/null)
  if [ -n "$text" ]; then
    printf '%s' "$text"
    exit
  fi
fi

[ -n "${TMUX:-}" ] && tmux show-buffer 2>/dev/null
