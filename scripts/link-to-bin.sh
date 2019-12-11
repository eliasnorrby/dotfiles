#!/usr/bin/env bash

SRC=$1
DEST=${2:-$SRC}

if [ -z "$SRC" ] || ! ls $SRC >/dev/null 2>&1 || echo $SRC $DEST | grep "/" >/dev/null 2>&1 ; then
  echo "Invalid arguments: $1 , $2"
  exit 1
fi

if [ ! -x "$SRC" ] ; then
  echo "Script is not executable, exiting"
  exit 1
fi

ln -snvf $(pwd)/$SRC $XDG_BIN_HOME/$DEST
