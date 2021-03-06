#!/bin/sh

VPN_PID=$(pgrep -x openfortivpn)
if [ -n "$VPN_PID" ]; then
  sudo kill -SIGINT "$VPN_PID"
fi
