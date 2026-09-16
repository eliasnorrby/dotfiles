#!/bin/sh

# Toggles espanso service on/off

if espanso service status | grep -q "running"; then
  espanso service stop
  notify-send "Espanso" "Espanso service stopped"
else
  espanso service start
  # A fresh worker starts on layout 0; re-press the layout key once it is
  # reading input so it catches up with the compositor.
  sleep 3
  switch_layout sync
fi
