#!/usr/bin/env zsh

source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/env
source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/scripts/echos.sh

SPACE="\n"
ping -q -c 1 -W 1 8.8.8.8 >/dev/null || (echo "No internet access."; exit 1)

# zsh
zsh_log=$(mktemp)
echo "$SPACE"
echo-info "Updating zsh plugins..."
git submodule update --recursive --remote | tee $zsh_log
echo-ok "zsh updated!"
echo-info "Wrote logs to $zsh_log"

# vim
echo "$SPACE"
echo-info "Updating vim-plug plugins..."
nvim +'PlugInstall --sync' +PlugUpdate +PlugUpgrade +qall
echo-ok "vim-plug updated!"

if [[ "$(_os)" == "macos" ]]; then
  # brew
  brew_log=$(mktemp)
  echo "$SPACE"
  echo-info "Updating brew formulas..."
  brew update && brew upgrade && brew cleanup | tee $brew_log
  echo-ok "brew updated!"
  echo-info "Wrote logs to $brew_log"

  # brew casks
  brew_cask_log=$(mktemp)
  echo "$SPACE"
  echo-info "Updating brew casks..."
  brew upgrade --cask | tee $brew_cask_log
  echo-ok "brew casks updated!"
  echo-info "Wrote logs to $brew_cask_log"
fi

# emacs
if _is_callable doom ; then
  doom_log=$(mktemp)
  echo "$SPACE"
  echo-info "Upgrading doom..."
  doom --yes upgrade | tee $doom_log
  echo-ok "doom upgraded!"
  echo-info "Wrote logs to $doom_log"
  echo "$SPACE"
fi

# npm
if _is_callable npm ; then
  npm_log=$(mktemp)
  echo "$SPACE"
  echo-info "Upgrading global npm packages..."
  npm upgrade -g | tee $npm_log
  echo-ok "npm packages upgraded!"
  echo-info "Wrote logs to $npm_log"
  echo "$SPACE"
fi

# TODO: global gem/pip packages
# TODO: grep logs to find number of packages updated

# finish up
echo-info "Logs available at:"
echo "  zsh: $zsh_log"
echo "  brew: $brew_log"
echo "  brew cask: $brew_cask_log"
echo "  doom: $doom_log"
echo "  npm: $npm_log"
echo-ok "Done!"

