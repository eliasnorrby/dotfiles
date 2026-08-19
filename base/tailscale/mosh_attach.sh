#!/bin/sh

# Connect to a host with mosh and attach to a tmux session, creating it if it
# does not exist yet. Keeping the session on the remote end means shell state
# and long-running processes survive disconnects and switching machines.
#
# Usage: mosh_attach <host> [session]

if [ $# -lt 1 ]; then
  echo "usage: ${0##*/} <host> [session]" >&2
  exit 1
fi

host=$1
session=${2:-main}

exec mosh "$host" -- tmux new-session -A -s "$session"
