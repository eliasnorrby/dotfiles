#!/usr/bin/env bash

# curl -sO https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh
# chmod +x setup.sh
# ./setup.sh

# Prerequisites:
#
# xcode-select --install # Or installing xcode from the app store
# xcodebuild -license accept

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

function _msg() { printf "\r\033[2K\033[0;32m[ SETUP ] %s\033[0m\n" "$*"; }

function _prompt() {
  _msg "$1"
  read -p "Press Enter to continue"
}

function install_homebrew() {
  _msg "Installing homebrew..."
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh -o install-homebrew.sh
  chmod +x install-homebrew.sh
  ./install-homebrew.sh
  _msg "Done!"
}

function install_python_and_openssl() {
  _msg "Installing updated versions of python and openssl..."
  brew install python3 openssl
  _msg "Done!"
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

_prompt "Next step: installing homebrew"

install_homebrew

_prompt "Next step: installing python and openssl"

install_python_and_openssl

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

