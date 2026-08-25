#!/bin/sh

# Connect to a host with mosh and attach to a tmux session, creating it if it
# does not exist yet. Keeping the session on the remote end means shell state
# and long-running processes survive disconnects and switching machines.
#
# -D detaches any other client already on that session. Two clients of
# different sizes otherwise fight over the window, since tmux sizes a window
# to whichever client was last active. Detaching costs nothing: the shells
# and anything running in them keep going.
#
# Usage: mosh_attach <host> [session]

if [ $# -lt 1 ]; then
  echo "usage: ${0##*/} <host> [session]" >&2
  exit 1
fi

host=$1
session=${2:-main}

exec mosh "$host" -- tmux new-session -A -D -s "$session"
