#!/usr/bin/env zsh

# === Utilities ===


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

BELL_CHARACTER=$(tput bel)
bell() {
  printf "%s" "$BELL_CHARACTER"
}

if [[ "$(_os)" == arch ]]; then
  notify_me() {
    notify-send "Done!" "Command execution complete"
    bell
  }
elif [[ "$(_os)" == macos ]]; then
  notify_me() {
    terminal-notifier -title "Done!" -message "Command execution complete"
    bell
  }
fi

alias n="notify_me"

alias -g N="; notify_me"
