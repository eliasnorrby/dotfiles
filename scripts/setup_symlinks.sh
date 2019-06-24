#!/bin/bash

ln -svnf ~/.dotfiles/zshrc.zsh ~/.zshrc
ln -svnf ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -svnf ~/.dotfiles/vimrc.vim ~/.vimrc 
ln -svnf ~/.dotfiles/gvimrc.vim ~/.gvimrc 
ln -svnf ~/.dotfiles/vim/colors ~/.vim/colors
ln -svnf ~/.dotfiles/eslintrc.json ~/.eslintrc
ln -svnf ~/.dotfiles/gitignore_global ~/.gitignore_global
ln -svnf ~/.dotfiles/prettierrc.json ~/.prettierrc
ln -svnf ~/.dotfiles/doom.d ~/.doom.d

if [[ "$(uname)" = "Darwin" ]]; then
  # Remember to also put init.lua in hammerspoon dir (require('keyboard'))
  echo "require('keyboard')" >> ~/.hammerspoon/init.lua
  ln -svnf ~/.dotfiles/keyboard/hammerspoon ~/.hammerspoon/keyboard
  # It might be a good idea to make a copy of the existing karabiner folder...
  ln -svnf ~/.dotfiles/keyboard/karabiner ~/.config/karabiner
  ln -svnf ~/.dotfiles/alacritty.yml ~/.config/alacritty
fi

