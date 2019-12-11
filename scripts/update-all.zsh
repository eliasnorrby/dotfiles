#!/usr/bin/env zsh

source $(cd ${${(%):-%x}:A:h}/.. && pwd -P)/env

# zplug
_load shell/zsh/plugins.zsh
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
