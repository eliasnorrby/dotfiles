#!/bin/sh

pgrep -x dunst > /dev/null || dunst &
