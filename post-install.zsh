#!/usr/bin/env zsh
#
# This is a collection of steps that don't play well with ansible. It should be
# run as the last step of bootstrap.sh to complete the installation.

source $(cd ${${(%):-%x}:A:h} && pwd -P)/env

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

# zplug
_msg "-- zplug --"
_msg "Sourcing plugins..."
_load shell/zsh/plugins.zsh

_msg "Running zplug install..."
zplug install

# vim-plug
_msg "-- vim-plug --"
_msg "Running PlugInstall..."
vim +'PlugInstall --sync' +qall

# emacs
_msg "-- doom --"
_msg "Running doom refresh..."
doom refresh --yes

_msg "Done!"
