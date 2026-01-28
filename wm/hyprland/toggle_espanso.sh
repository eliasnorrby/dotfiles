#!/bin/sh

# Toggles espanso service on/off

if espanso service status | grep -q "running"; then
  espanso service stop
  notify-send "Espanso" "Espanso service stopped"
else
  espanso service start
fi
