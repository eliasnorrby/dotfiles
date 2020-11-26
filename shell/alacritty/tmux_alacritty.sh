#!/bin/sh

alacritty --class TmuxAlacritty,TmuxAlacritty -e zsh -i -c ta &
sleep 0.6
xdotool search --class TmuxAlacritty key Return
