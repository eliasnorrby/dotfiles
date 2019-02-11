#!/bin/bash

ln -svnf ~/.dotfiles/zshrc.zsh ~/.zshrc
ln -svnf ~/.dotfiles/aliases.zsh ~/.zsh_aliases
ln -svnf ~/.dotfiles/plugins.zsh ~/.zsh_plugins
ln -svnf ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -svnf ~/.dotfiles/tmux.remote.conf ~/.tmux.remote.conf
ln -svnf ~/.dotfiles/vimrc.vim ~/.vim/vimrc 

if [[ "$(uname)" = "Darwin" ]]; then
  # Remember to also put init.lua in hammerspoon dir (require('keyboard'))
  echo "require('keyboard')" >> ~/.hammerspoon/init.lua
  ln -svnf ~/.dotfiles/keyboard/hammerspoon ~/.hammerspoon/keyboard
  # It might be a good idea to make a copy of the existing karabiner folder...
  ln -svnf ~/.dotfiles/keyboard/karabiner ~/.config/karabiner
fi
