#!/usr/bin/env bash

SECONDS=0

# DEFAULTS
DO_MAS=${DO_MAS:-false}
ASK_PASS=${ASK_PASS:-true}
DO_POST_INSTALL=${DO_POST_INSTALL:-true}
DEBUG=${DEBUG:-false}

if [ -z "$DOTFILES_VERSION" ]; then
  DOTFILES_VERSION=${1:-master}
fi

ANSIBLE_TAGS=${ANSIBLE_TAGS:-all,do_pacman,do_packages}
ANSIBLE_FLAGS=-v

if [[ "$DO_MAS" == true ]]; then
  ANSIBLE_TAGS="${ANSIBLE_TAGS},do_mas"
fi

if [[ "$ASK_PASS" == true ]]; then
  # Ask for sudo password (possibly required for homebrew role)
  ANSIBLE_FLAGS="${ANSIBLE_FLAGS} -K"
fi

if [[ "$DEBUG" == true ]]; then
  set -x
fi

set -eo pipefail

export DOTFILES_REPO="https://github.com/eliasnorrby/dotfiles"
export TARBALL_URL="$DOTFILES_REPO/tarball/$DOTFILES_VERSION"
export DOTFILES=~/.dotfiles

function _msg() { printf "\r\033[2K\033[0;32m[ SETUP ] %s\033[0m\n" "$*"; }

function _prompt() {
  _msg "$1"
  read -p "[ ..... ] Press Enter to continue"
}

function get_repo_snapshot() {
  _msg "Downloading repository snapshot from eliasnorrby/dotfiles@$DOTFILES_VERSION..."
  curl -sL "$TARBALL_URL" | tar xz
}

function install_ansible_and_roles() {
  _msg "Installing ansible and required roles..."
  pip3 install ansible
  ansible-galaxy install -r requirements.yml -p ./roles
  _msg "Done!"
}

function run_playbook() {
  _msg "Running the playbook..."
  ansible-playbook playbook.yml --tags "$ANSIBLE_TAGS" $ANSIBLE_FLAGS
}

function print_duration() {
  ELAPSED="$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"

  _mg "Setup completed in $ELAPSED"
}

_prompt "Next step: downloading repo"

cd "$(mktmp -d)"

get_repo_snapshot

cd eliasnorrby-dotfiles*
cd _provision

_prompt "Next step: installing ansible and roles"

install_ansible_and_roles

_prompt "Next step: running playbook"

run_playbook

_prompt "Next step: running post-install script"

if [[ "$DO_POST_INSTALL" == true ]]; then
  _msg "Running post-install script..."
  cd "$DOTFILES"
  ./post-install.zsh
fi

_msg "Done!"

