#!/bin/sh

pgrep -x picom > /dev/null || picom --experimental-backends &
