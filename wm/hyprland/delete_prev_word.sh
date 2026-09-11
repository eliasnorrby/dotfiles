#!/bin/sh

# Remap Ctrl+W to Ctrl+Backspace for non-terminal windows.
# In terminals, Ctrl+W already deletes the previous word natively.
# Uses sendshortcut instead of wtype: wtype's virtual keyboard hijacks
# the active xkb layout and blanks the layout indicator.

class=$(hyprctl activewindow -j | jq -r '.class')

case "$class" in
  *[Kk]itty* | *[Aa]lacritty* | *[Ff]oot* | *[Ww]ezterm* | org.gnome.[Tt]erminal*)
    hyprctl dispatch sendshortcut "CTRL, W, activewindow"
    ;;
  *)
    hyprctl dispatch sendshortcut "CTRL, BackSpace, activewindow"
    ;;
esac
