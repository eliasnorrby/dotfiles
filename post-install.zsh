#!/usr/bin/env zsh
#
# This is a collection of steps that don't play well with ansible. It should be
# run as the last step of bootstrap.sh to complete the installation.

DIR=$(cd ${${(%):-%x}:A:h} && pwd -P)
source "$DIR"/env

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

# zplug
if _is_callable zplug ; then
  _msg "-- zplug --"
  _msg "Sourcing plugins..."
  _load shell/zsh/plugins.zsh
  _msg "Running zplug install..."
  zplug install
fi

# vim-plug
if _is_callable nvim ; then
  _msg "-- vim-plug --"
  _msg "Running PlugInstall..."
  nvim +'PlugInstall --sync' +qall
  _msg "Installing coc-nvim extensions..."
  cd ~/.config/coc/extensions
  npm install
  cd -
fi

# emacs
if _is_callable doom ; then
  _msg "-- doom --"
  _msg "Running doom sync..."
  doom --yes sync
fi

# vscode
if _is_callable code ; then
  _msg "-- vscode --"
  _msg "Installing extensions..."
  "$DIR/editor/vscode/install-extensions.zsh"
fi

_msg "Done!"
