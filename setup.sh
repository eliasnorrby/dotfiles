#!/usr/bin/env bash

# Theoretically, this script can be ran with curl, i.e.
#
#   bash <(curl -sL https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh)
#
# but it's probably better to download it to take a look first:
#
#   curl -sLO https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh
#   chmod +x setup.sh
#   ./setup.sh
#
# === Configuration ===
# There are a number of environment variables you can set prior to
# running this script in order to customize its behaviour.
#
# DOTFILES_VERSION=master|develop|... (default: master)
#   Select which branch to download a snapshot of.
# DO_MAS=true|false (default: true)
#   Enable to install Mac App Store apps. Make sure you log into the
#   App Store app with your Apple ID first.
# ASK_PASS=true|false (default: true)
#   Add the -K (--ask-become-pass) flag to ansible-playbook. This may
#   or may not be needed to properly install homebrew.
# DO_POST_INSTALL=true|false (default: true)
#   Choose whether to run the post-install script or not. Mainly used to get
#   around the time limit for jobs on travis-ci.com.
#
# DEBUG=true (default: false)
#   Make this script more verbose (set -x).
#
# Extended example:
#
#   DO_MAS=false bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh)
#
# === Prerequisites ===
# One may or may not need to install the xcode command line tools before
# running this script.
#
#   xcode-select --install # Or installing xcode from the app store
#   xcodebuild -license accept
#
# but it's possible homebrew will take care of it.

SECONDS=0

# DEFAULTS
DO_MAS=${DO_MAS:-true}
ASK_PASS=${ASK_PASS:-true}
DO_POST_INSTALL=${DO_POST_INSTALL:-true}
DEBUG=${DEBUG:-false}

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

