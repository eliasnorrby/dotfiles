#!/usr/bin/env zsh

# === Utilities ===

if [[ "$(_os)" == "macos" ]] ; then
  copy_cmd() {
    pbcopy
  }
else
  copy_cmd() {
    xclip -selection clipboard
  }
fi

get_copy_cmd() {
  if [[ "$(_os)" == "macos" ]] ; then
    echo "pbcopy"
  else
    echo "xsel -b"
  fi
}

mkd() {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

backup() {
  [ "$#" -ne 1 ] || [ ! -e "$1" ] && { echo "Usage: backup <file/directory>" && return; }
  local file=$1 backup
  backup="$file.bak"
  [ -e "$backup" ] && { echo "$backup already exists" && return; }
  echo "$file -> $backup"
  mv "$file" "$backup"
}

unbackup() {
  [ "$#" -ne 1 ] || [ ! -e "$1" ] && { echo "Usage: unbackup <file/directory>" && return; }
  local file backup=$1
  file="${backup%.bak}"
  [ -e "$file" ] && { echo "$file already exists" && return; }
  echo "$backup -> $file"
  mv "$backup" "$file"
}

color() {
  print -P -- "$1: %F{$1}This is what your text would look like%f";
}

list_colors_short() {
  for code ({00..15}) print -P -- "$code: %F{$code}This is what your text would look like%f";
}

list_colors_long() {
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
