#!/usr/bin/env zsh
#
# This is a collection of steps that don't play well with ansible. It should be
# run as the last step of bootstrap.sh to complete the installation.

DIR=$(cd ${${(%):-%x}:A:h} && pwd -P)
source "$DIR"/env

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

# install tmux terminfo
if [[ "$(_os)" == "macos" ]]; then
  tic -x "$DIR/assets/tmux.terminfo"
fi

# vim-plug
if _is_callable nvim ; then
  _msg "-- vim-plug --"
  _msg "Running PlugInstall..."
  nvim +'PlugInstall --sync' +qall
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

# node corepack
if _is_callable corepack ; then
  _msg "-- node --"
  _msg "Enabling corepack..."
  corepack enable
fi

# ansible
_msg "-- ansible --"
_msg "Installing playbook roles..."
cd "$DOTFILES/_provision"
ansible-galaxy install -r requirements.yml
cd -

_msg "Done!"
