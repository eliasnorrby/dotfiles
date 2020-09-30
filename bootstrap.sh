#!/usr/bin/env bash
#
# This script is intended to be run with curl, i.e.
#
# bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)
#
#
# # Configuration
# There are a number of environment variables you can set prior to
# running this script in order to customize its behaviour.
#
# DOTFILES_VERSION=master|develop|... (default: master)
#   Select which branch to download a snapshot of
# DO_MAS=true (default: false)
#   Enable to install Mac App Store apps. Make sure you log into the
#   App Store app with your Apple ID first.
# ASK_PASS=true (default: false)
#   Add the -K (--ask-become-pass) flag to ansible-playbook. This may
#   or may not be needed to properly install homebrew.
# DO_POST_INSTALL=false (default: true)
#   Avoid running the post install script. Mainly used to get around
#   the time limit for jobs on travis-ci.com.
#
# # Extended example:
#
# DO_MAS=true ASK_PASS=true bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)
#

SECONDS=0

if [ -z "$DOTFILES_VERSION" ]; then
  DOTFILES_VERSION=${1:-master}
fi

ANSIBLE_TAGS=${ANSIBLE_TAGS:-all,setup_homebrew,do_homebrew,do_packages,do_defaults}
ANSIBLE_FLAGS=-v

if [[ "$DO_MAS" == true ]]; then
  ANSIBLE_TAGS="${ANSIBLE_TAGS},do_mas"
fi

if [[ "$ASK_PASS" == true ]]; then
  # Ask for sudo password (possibly required for homebrew role)
  ANSIBLE_FLAGS="${ANSIBLE_FLAGS} -K"
fi

DO_POST_INSTALL=${DO_POST_INSTALL:-true}

set -exo pipefail

export DOTFILES_REPO="https://github.com/eliasnorrby/dotfiles"
export TARBALL_URL="$DOTFILES_REPO/tarball/$DOTFILES_VERSION"
export DOTFILES=~/.dotfiles

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

_get_repo_snapshot() {
  curl -sL $TARBALL_URL | tar xz
}

# check if a command is available
function _is_callable() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null || return 1
  done
}

_msg "Downloading repository snapshot from eliasnorrby/dotfiles@$DOTFILES_VERSION..."
cd $(mktemp -d)
_get_repo_snapshot
cd eliasnorrby-dotfiles*

if ! _is_callable python3; then
  _msg "Installing python 3..."
  curl "https://www.python.org/ftp/python/3.7.9/python-3.7.9-macosx10.9.pkg" -o "python3.pkg"
  sudo installer -pkg python3.pkg -target /
  export PATH=/Library/Frameworks/Python.framework/Versions/3.7/bin:$PATH
else
  _msg "python 3 already installed"
fi

if ! _is_callable pip3; then
  _msg "Installing pip..."
  curl https://bootstrap.pypa.io/get-pip.py | sudo python3
else
  _msg "pip already installed"
fi

cd _provision

if ! _is_callable ansible; then
  _msg "Installing ansible..."
  sudo -H pip3 install ansible

  _msg "Installing playbook requirements..."
  ansible-galaxy install -r requirements.yml
else
  _msg "ansible already installed"
fi

_msg "Running the playbook..."
ansible-playbook playbook.yml --tags "$ANSIBLE_TAGS" "$ANSIBLE_FLAGS"

if [[ "$DO_POST_INSTALL" == true ]]; then
  _msg "Run post-install script..."
  cd $DOTFILES
  ./post-install.zsh
fi

_msg "Done!"

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

_msg "Setup completed in $ELAPSED"
