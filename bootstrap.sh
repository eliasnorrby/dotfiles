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
# DOTFILES_VERSION: (master|develop|...)
#   Select which branch to download a snapshot of
# DO_MAS: (true)
#   Enable to install Mac App Store apps. Make sure you log into the
#   App Store app with your Apple ID first.
# ASK_PASS: (true)
#   Add the -K (--ask-become-pass) flag to ansible-playbook. This may
#   or may not be needed to properly install homebrew.
#
# # Extended example:
#
# DO_MAS=true ASK_PASS=true bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)
#

SECONDS=0

if [ -z "$DOTFILES_VERSION" ] ; then
  DOTFILES_VERSION=${1:-master}
fi

ANSIBLE_TAGS='all,setup_homebrew,do_homebrew,do_packages,do_defaults'
ANSIBLE_FLAGS=''

if [ "$DO_MAS" == true ]; then
  ANSIBLE_TAGS="${ANSIBLE_TAGS},do_mas"
fi

if [ "$ASK_PASS" == true ]; then
  # Ask for sudo password (possibly required for homebrew role)
  ANSIBLE_FLAGS="-K"
fi

set -exo pipefail

export DOTFILES_REPO="https://github.com/eliasnorrby/dotfiles"
export TARBALL_URL="$DOTFILES_REPO/tarball/$DOTFILES_VERSION"
export DOTFILES=~/.dotfiles

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

_get_repo_snapshot() {
  curl -sL $TARBALL_URL | tar xz
}

_msg "Downloading repository snapshot from eliasnorrby/dotfiles@$DOTFILES_VERSION..."
cd $(mktemp -d)
_get_repo_snapshot
cd eliasnorrby-dotfiles*

_msg "Installing pip..."
sudo easy_install pip

_msg "Installing ansible..."
sudo pip install ansible

_msg "Installing playbook requirements..."
cd _provision
ansible-galaxy install -r requirements.yml

_msg "Running the playbook..."
ansible-playbook playbook.yml --tags "$ANSIBLE_TAGS" "$ANSIBLE_FLAGS" -v

_msg "Run post-install script..."
cd $DOTFILES
./post-install.zsh

_msg "Done!"

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

_msg "Setup completed in $ELAPSED"
