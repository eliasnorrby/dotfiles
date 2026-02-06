#!/bin/sh

status=$(hyprvoice status 2>/dev/null | grep -oP 'status=\K\w+')

case "$status" in
  transcribing)
    class="active"
    text=""
    ;;
  injecting)
    class="active"
    text=""
    ;;
  processing)
    class="active"
    text=""
    ;;
  *)
    class="idle"
    text=""
    ;;
esac

printf '{"text": "%s", "class": "%s", "tooltip": "hyprvoice: %s"}\n' \
  "$text" "$class" "${status:-unknown}"
