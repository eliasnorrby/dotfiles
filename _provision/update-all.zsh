#!/usr/bin/env zsh

source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/env
source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/scripts/echos.sh

SPACE="\n"
ping -q -c 1 -W 1 8.8.8.8 >/dev/null || (echo "No internet access."; exit 1)

# zplug
zplug_log=$(mktemp)
echo "$SPACE"
echo-info "Updating zplug plugins..."
_load shell/zsh/plugins.zsh
zplug check || zplug install | tee $zplug_log
zplug update | tee -a $zplug_log
echo-ok "zplug updated!"
echo-info "Wrote logs to $zplug_log"

# vimplug
# vim +'PlugInstall --sync' +qall
# vim +'PlugUpdate' +qall
# vim +'PlugUpgrade' +qall

# or
vim_plug_log=$(mktemp)
echo "$SPACE"
echo-info "Updating vim-plug plugins..."
nvim +'PlugInstall --sync' +PlugUpdate +PlugUpgrade +qall | tee $vim_plug_log
echo-ok "vim-plug updated!"
echo-info "Updating coc-nvim extensions..."
nvim +CocUpdateSync +qall
echo-ok "coc-nvim updated!"
echo-info "Wrote logs to $vim_plug_log"

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
brew cask upgrade | tee $brew_cask_log
echo-ok "brew casks updated!"
echo-info "Wrote logs to $brew_cask_log"

# emacs
doom_log=$(mktemp)
echo "$SPACE"
echo-info "Upgrading doom..."
doom --yes upgrade | tee $doom_log
echo-ok "doom upgraded!"
echo-info "Wrote logs to $doom_log"
echo "$SPACE"

# npm
npm_log=$(mktemp)
echo "$SPACE"
echo-info "Upgrading global npm packages..."
npm upgrade -g | tee $npm_log
echo-ok "npm packages upgraded!"
echo-info "Wrote logs to $npm_log"
echo "$SPACE"

# TODO: global gem/pip packages
# TODO: grep logs to find number of packages updated

# finish up
echo-info "Logs available at:"
echo "  zplug: $zplug_log"
echo "  vim_plug: $vim_plug_log"
echo "  brew: $brew_log"
echo "  brew cask: $brew_cask_log"
echo "  doom: $doom_log"
echo "  npm: $npm_log"
echo-ok "Done!"

