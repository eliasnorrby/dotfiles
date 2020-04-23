#!/usr/bin/env bash

echo "> Installing test dependencies..."

brew_taps=(
  # add taps if needed
)

brew_formulae=(
  zsh
  python
  vim
  jq
  yq
)

brew_casks=(
  # add casks if needed
)

if [ ! -z "$brew_taps" ] ; then
  echo ">> Tap brew taps..."
  for tap in ${brew_taps[@]}; do
    brew tap $tap
  done
  echo
fi

if [ ! -z "$brew_formulae" ] ; then
  echo ">> Install brew formulae..."
  brew install ${brew_formulae[@]}
  echo
fi

if [ ! -z "$brew_casks" ] ; then
  echo ">> Install brew casks..."
  brew cask install ${brew_casks[@]}
  echo
fi
