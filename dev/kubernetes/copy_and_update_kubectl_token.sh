#!/bin/sh

timeout=2000

xsel --clear

# Copy token from browser tab using vimium
sleep 1; xdotool key --delay 50 slash s h a KP_Enter V y

token=$(xsel -o)
if [ -z "$token" ] || [ "${token#sha}" = "${token}" ]; then
  notify-send -t $timeout -u CRITICAL "Could not copy token"
  exit 1
fi

if update_kubectl_token "$token"; then
  notify-send -t $timeout "Token updated successfully"
else
  notify-send -t $timeout -u CRITICAL "Failed to update token"
fi
