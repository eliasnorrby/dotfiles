#!/usr/bin/env bash
# screen_record - wrapper for wf-recorder with waybar integration

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
START_FILE="$RUNTIME_DIR/screen_record.start"
OUTPUT_DIR="$HOME/Videos/Recordings"

start_recording() {
  local geometry="$1"
  local output_file="$OUTPUT_DIR/screen-$(date +%Y%m%d-%H%M%S).mp4"

  # Store start time
  date +%s >"$START_FILE"

  # Start recording (blocks until stopped)
  if [[ -n "$geometry" ]]; then
    wf-recorder -g "$geometry" --file "$output_file"
  else
    wf-recorder --file "$output_file"
  fi

  # Clean up and copy to clipboard
  rm -f "$START_FILE"
  if [[ -f "$output_file" ]]; then
    echo "file://$output_file" | wl-copy -t text/uri-list
  fi
}

case "$1" in
  fullscreen)
    start_recording
    ;;

  region)
    geometry=$(slurp)
    if [[ -n "$geometry" ]]; then
      start_recording "$geometry"
    fi
    ;;

  stop)
    pkill wf-recorder
    rm -f "$START_FILE"
    ;;

  status)
    pgrep wf-recorder >/dev/null
    ;;

  panel)
    if ! pgrep wf-recorder >/dev/null; then
      # echo ''
      exit 0
    fi

    if [[ -f "$START_FILE" ]]; then
      start_time=$(cat "$START_FILE")
      now=$(date +%s)
      elapsed=$((now - start_time))
      minutes=$((elapsed / 60))
      seconds=$((elapsed % 60))
      printf '{"text":" %d:%02d","tooltip":"Recording: %dm %ds - click to stop","class":"recording"}\n' \
        "$minutes" "$seconds" "$minutes" "$seconds"
    fi
    ;;

  *)
    echo "Usage: screen_record {fullscreen|region|stop|status|panel}"
    exit 1
    ;;
esac
