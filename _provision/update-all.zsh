#!/usr/bin/env zsh

source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/env
source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/scripts/echos.sh

SPACE="\n"
ping -q -c 1 -W 1 8.8.8.8 >/dev/null || (echo "No internet access."; exit 1)

# zplug
echo "$SPACE"
echo-info "Updating zplug plugins..."
_load shell/zsh/plugins.zsh
zplug check || zplug install
zplug update
echo-ok "zplug updated!"

# vimplug
# vim +'PlugInstall --sync' +qall
# vim +'PlugUpdate' +qall
# vim +'PlugUpgrade' +qall

# or
echo "$SPACE"
echo-info "Updating vim-plug plugins..."
vim +'PlugInstall --sync' +PlugUpdate +PlugUpgrade +qall
echo-ok "vim-plug updated!"

# brew
echo "$SPACE"
echo-info "Updating brew formulas..."
brew update && brew upgrade && brew cleanup
echo-ok "brew updated!"

# emacs
echo "$SPACE"
echo-info "Upgrading doom..."
doom --yes upgrade
echo-ok "doom upgraded!"
echo "$SPACE"
