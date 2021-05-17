#!/bin/sh

# Super simple Spotify controls
# Usage:
# spotifyctl <PlayPause|Next|Previous>

send() {
  dbus-send \
    --type=method_call \
    --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 \
    "org.mpris.MediaPlayer2.Player.$1"
}

case "$1" in
  PlayPause) send PlayPause ;;
  Next) send Next ;;
  Previous) send Previous ;;
  *) exit 1 ;;
esac
