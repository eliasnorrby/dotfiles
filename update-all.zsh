#!/usr/bin/env zsh

# TODO: borrow hlissners _is_callable script

# zplug
ZPLUG_PLUGS="${HOME}/.dotfiles/plugins.zsh"
. ${ZPLUG_PLUGS}
zplug check || zplug install
zplug update

# vimplug
# vim +'PlugInstall --sync' +qall
# vim +'PlugUpdate' +qall
# vim +'PlugUpgrade' +qall

# or
vim +'PlugInstall --sync' +PlugUpdate +PlugUpgrade +qall

# brew
# brew update && brew upgrade && brew cleanup

# emacs
# doom upgrade --yes
