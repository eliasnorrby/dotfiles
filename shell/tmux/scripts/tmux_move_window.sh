#!/usr/bin/env bash
# Move the current window to another session and follow it (which-cmd w>m).
#
# The target is passed as a bare session name. It is suffixed with ":" before
# use: an unsuffixed target-window resolves against window names in the current
# session first, so a window sharing a name with the target session would
# hijack the move ("index in use").
#
# move-window only decides which window is current inside the destination; the
# client stays attached to the source session, so we switch it explicitly.
set -euo pipefail

session=${1:-}

if [ -z "$session" ]; then
  echo "Usage: tmux_move_window <session>" >&2
  exit 1
fi

tmux move-window -t "$session:"
tmux switch-client -t "$session:"
