#!/bin/sh

# Wrapper for hyprvoice toggle that manages system volume during recording.
# When starting recording: saves current volume and lowers it by 50%
# When stopping recording: restores the saved volume

VOLUME_FILE="${XDG_RUNTIME_DIR:-/tmp}/hyprvoice_saved_volume"

get_volume() {
  # wpctl get-volume outputs: "Volume: 0.50" (where 0.50 = 50%)
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'
}

set_volume() {
  wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"
}

is_recording() {
  hyprvoice status 2>/dev/null | grep -qi "transcribing"
}

if is_recording; then
  # Currently recording - stop and restore volume gradually
  hyprvoice toggle

  if [ -f "$VOLUME_FILE" ]; then
    saved_volume=$(cat "$VOLUME_FILE")
    current_volume=$(get_volume)
    rm -f "$VOLUME_FILE"

    # Gradually restore volume over ~1.5 seconds (10 steps, 150ms each)
    steps=10
    i=1
    while [ "$i" -le "$steps" ]; do
      vol=$(echo "$current_volume $saved_volume $i $steps" | awk '{
        printf "%.2f", $1 + ($2 - $1) * ($3 / $4)
      }')
      set_volume "$vol"
      sleep 0.15
      i=$((i + 1))
    done
  fi
else
  # Not recording - start recording, save volume, then lower it gradually
  hyprvoice toggle

  current_volume=$(get_volume)

  if [ -n "$current_volume" ]; then
    echo "$current_volume" >"$VOLUME_FILE"
    lowered_volume=$(echo "$current_volume" | awk '{printf "%.2f", $1 * 0.4}')

    # Gradually lower volume over ~0.5 seconds (5 steps, 100ms each)
    steps=5
    i=1
    while [ "$i" -le "$steps" ]; do
      vol=$(echo "$current_volume $lowered_volume $i $steps" | awk '{
        printf "%.2f", $1 + ($2 - $1) * ($3 / $4)
      }')
      set_volume "$vol"
      sleep 0.1
      i=$((i + 1))
    done
  fi
fi
