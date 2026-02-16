#!/bin/sh

# Remap Ctrl+W to Ctrl+Backspace for non-terminal windows.
# In terminals, Ctrl+W already deletes the previous word natively.

class=$(hyprctl activewindow -j | jq -r '.class')

case "$class" in
  *[Kk]itty* | *[Aa]lacritty* | *[Ff]oot* | *[Ww]ezterm* | org.gnome.[Tt]erminal*)
    wtype -M ctrl -k w -m ctrl
    ;;
  *)
    wtype -M ctrl -k BackSpace -m ctrl
    ;;
esac
