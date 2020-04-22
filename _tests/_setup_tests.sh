#!/usr/bin/env bash

echo "> Installing test dependencies..."

brew_taps=(
d12frosted/emacs-plus
)

brew_formulae=(
zsh
vim
jq
yq
emacs-plus
)

brew_casks=(
vscode
)

echo ">> Tap brew taps..."
for tap in ${brew_taps[@]}; do
  brew tap $tap
done
echo

echo ">> Install brew formulae..."
brew install $brew_formulae
echo

echo ">> Install brew casks..."
brew cask install $brew_casks
echo
