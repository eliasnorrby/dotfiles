#!/bin/sh

if tmux list-sessions | cut -d ":" -f 1 | grep "vpn" >/dev/null; then
  echo "Tmux session 'vpn' already exists: the VPN is probably already up."
  sleep 3
  exit 1
fi

tmux new-session -s vpn vpn_connect
