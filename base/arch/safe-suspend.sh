#!/bin/sh

# Safe suspend wrapper that checks available memory before suspending.
# Prevents crashes caused by insufficient memory for GPU VRAM eviction.

# Minimum available memory required (in MB)
MIN_AVAILABLE_MB=4000

available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
available_mb=$((available_kb / 1024))

if [ "$available_mb" -lt "$MIN_AVAILABLE_MB" ]; then
  notify-send -u critical "Suspend aborted" \
    "Only ${available_mb}MB available (need ${MIN_AVAILABLE_MB}MB).\nClose some applications and try again."
  exit 1
fi

systemctl suspend
