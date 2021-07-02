#!/bin/sh

pgrep -x dropbox > /dev/null || dropbox &
pgrep -x udiskie > /dev/null || udiskie &
