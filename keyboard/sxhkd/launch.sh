#!/bin/sh

# sxhkd must be started after keybindings are set up.
# Config could be reloaded instead of forcing a restart, but it appears to be
# causing some inconsistent behaviour.

# pgrep -x sxhkd > /dev/null && pkill -USR1 -x sxhkd || sxhkd &

killall -q sxhkd
sxhkd &
