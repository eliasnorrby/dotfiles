#!/usr/bin/env bash

DIR="$( cd "$(dirname "${BASH_SORUCE[0]}")" && pwd )"
echo "DIR: $DIR"

echo "Clone doom emacs repo..."
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
echo

echo "Clone zplug repop..."
git clone https://github.com/zplug/zplug ~/.cache/zplug
echo

echo "Running post-install script..."
$DIR/../post-install.zsh
echo "Done!"
