#!/usr/bin/env bash

# A (possibly) cleaner approach would be to just run PlugUpgrade
# and check whether plug.vim.old has been modified

UPGRADE_LOG=$(vim +'PlugUpgrade' +qall 2>/dev/null)
grep -o "vim-plug has been upgraded" <<< "$UPGRADE_LOG" > /dev/null

if [ "$?" -eq 0 ] ; then
  echo -n "changed"
else
  echo -n "unchanged"
fi
