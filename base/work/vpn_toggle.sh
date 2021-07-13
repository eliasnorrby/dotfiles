#!/bin/sh

if pgrep -x openfortivpn >/dev/null; then
  sudo /usr/local/bin/vpn_disconnect
else
  alacritty_tmux_vpn_connect
fi
