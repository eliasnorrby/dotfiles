#!/bin/sh
# Copy stdin to the clipboard you are actually looking at.
#
# A tmux pane's environment is a snapshot of where it was born, not where it is
# being viewed: panes created in this machine's local session carry
# WAYLAND_DISPLAY, panes created inside a mosh session do not, and neither says
# anything about which screen is in front of you right now. tmux does know --
# it tracks the attached client -- so inside tmux the text is handed to tmux,
# which forwards it to that client's terminal with OSC 52. The clipboard that
# receives it is therefore the one you are looking at, local or remote.
#
# The machine's own clipboard is written too, so a copy made here stays
# readable from panes that have no Wayland connection of their own.
set -u

payload=$(mktemp) || exit 1
trap 'rm -f "$payload"' EXIT
cat >"$payload"

# Nothing to copy: leave whatever is on the clipboard alone rather than
# clearing it.
[ -s "$payload" ] || exit 0

# Point wl-clipboard at the running compositor. A pane born in a mosh session
# inherits no Wayland environment, but the compositor is running all the same,
# so the socket only needs locating.
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

# This machine's own clipboard.
copy_local() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy <"$payload"
  elif command -v wl-copy >/dev/null 2>&1 && find_wayland; then
    # wl-copy forks a process to hold the selection; detaching its output keeps
    # callers from waiting on a pipe that never sees EOF.
    wl-copy <"$payload" >/dev/null 2>&1
  fi
}

# Hand the text to every attached client's terminal as an OSC 52 write.
#
# tmux can be told to do this itself with set-clipboard, but it emits the
# sequence with an empty selection parameter -- \033]52;;... -- and mosh only
# recognises the explicit \033]52;c; form, so it drops tmux's variant on the
# floor. That single mismatch is why a copy made over mosh never arrived.
# Addressing the client terminals directly sidesteps it, and still follows
# whichever client is attached rather than guessing from this pane's
# environment.
osc52_to_clients() {
  encoded=$(base64 <"$payload" | tr -d '\n')
  tmux list-clients -F '#{client_tty}' 2>/dev/null | while IFS= read -r tty; do
    [ -w "$tty" ] || continue
    printf '\033]52;c;%s\007' "$encoded" >"$tty"
  done
}

if [ -n "${TMUX:-}" ]; then
  # A named buffer, reused rather than stacking a new one on every copy, so the
  # text is also available to tmux's own paste.
  tmux load-buffer -b clipboard "$payload"
  osc52_to_clients
elif [ -n "${SSH_CONNECTION:-}" ] && [ -w /dev/tty ]; then
  # No tmux to enumerate clients: this terminal is the only candidate.
  printf '\033]52;c;%s\007' "$(base64 <"$payload" | tr -d '\n')" >/dev/tty
fi

copy_local
