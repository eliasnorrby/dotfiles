#!/usr/bin/env zsh

# === Utilities ===

# TODO: move to :tmux: functions.zsh
function tkey() {
  grep "$1" ~/.dotfiles/tmux/tmux-cheatsheet.md
}

# TODO: move to :tmux: functions.zsh
function tkeydocs() {
  vim ~/.dotfiles/tmux/tmux-cheatsheet.md
}

function mkd() {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

function color() {
  print -P -- "$1: %F{$1}This is what your text would look like%f";
}

function list_colors_short() {
  for code ({00..15}) print -P -- "$code: %F{$code}This is what your text would look like%f";
}

function list_colors_long() {
  for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f";
}
