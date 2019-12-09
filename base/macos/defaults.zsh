#!/usr/bin/env zsh

# TODO: These are not in use, but kept for reference. I should find a good way
# to apply them from the development playbook.

defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
