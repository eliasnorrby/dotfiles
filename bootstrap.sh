#!/usr/bin/env bash
#
# This script is intended to be run with curl, i.e.
#
# bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)

SECONDS=0

set -exo pipefail

export DOTFILES=~/.dotfiles

_msg() { printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"; }

_get_release_version() {
  local release_url="https://api.github.com/repos/eliasnorrby/mac-dev-playbook/releases"
  curl -sL $release_url | grep --color=never -m 1 '^ .*"tag_name"' | grep --color=never -oE '[0-9]+\.[0-9]+\.[0-9]+[^"]*'
}

_get_release_archive() {
  release=$1
  local url="https://github.com/eliasnorrby/mac-dev-playbook/archive/v${release}.tar.gz"
  curl -sL $url | tar xz
}

PLAYBOOK_RELEASE=$(_get_release_version)

_msg "Downloading release $PLAYBOOK_RELEASE..."
_get_release_archive $PLAYBOOK_RELEASE
cd mac-dev-playbook-${PLAYBOOK_RELEASE/v/}

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
