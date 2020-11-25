#!/bin/sh

pgrep -x dropbox > /dev/null || dropbox &
