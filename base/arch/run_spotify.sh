#!/bin/sh

DESKTOP=${1:-7}
bspc desktop --focus "^$DESKTOP"
spotify
