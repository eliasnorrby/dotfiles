#!/usr/bin/env bash
#
# This script is intended to be run with curl, i.e.
#
# bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)

SECONDS=0

set -exo pipefail

export DOTFILES=~/.dotfiles

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

_get_repo_snapshot() {
  local url="https://github.com/eliasnorrby/mac-dev-playbook/tarball/master"
  curl -sL $url | tar xz
}

_msg "Downloading playbook from eliasnorrby/mac-dev-playbook@master..."
cd $(mkdtemp -d)
_get_repo_snapshot
cd eliasnorrby-mac-dev-playbook*

_msg "Installing pip..."
sudo easy_install pip

_msg "Installing ansible..."
sudo pip install ansible

_msg "Installing playbook requirements..."
ansible-galaxy install -r requirements.yml

_msg "Running the playbook..."
ansible-playbook main.yml --tags 'all,do_homebrew' -v

_msg "Run post-install script..."
cd $DOTFILES
./post-install.zsh

_msg "Done!"

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

_msg "Setup completed in $ELAPSED"
