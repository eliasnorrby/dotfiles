#!/bin/sh

[ -z "$1" ] && echo "No dir specified" && exit 1

dir=$1
from_vim=$2

main() {
  map_dir "$dir"

  if ! is_tmux; then
    bspwm_select
    exit
  fi

  if [ -z "$from_vim" ] && is_vim; then
    vim_in_tmux_select
    exit 0
  fi

  if has_pane_in_dir; then
    tmux_select
  else
    bspwm_select
  fi
}

map_dir() {
  case $dir in
    l|left)    bspwm_dir=west    tmux_select_dir=L   tmux_lookup_dir=left     vim_key=h   ;;
    r|right)   bspwm_dir=east    tmux_select_dir=R   tmux_lookup_dir=right    vim_key=l   ;;
    u|up)      bspwm_dir=north   tmux_select_dir=U   tmux_lookup_dir=top      vim_key=k   ;;
    d|down)    bspwm_dir=south   tmux_select_dir=D   tmux_lookup_dir=bottom   vim_key=j   ;;
    *)
      echo "Invalid dir: $dir"
      exit 1
      ;;
  esac
}

bspwm_select() {
  bspc node --focus $bspwm_dir
}

tmux_select() {
  tmux select-pane "-${tmux_select_dir}"
}

vim_in_tmux_select() {
  tmux send-keys "C-${vim_key}"
}

is_tmux() {
  xprop -id "$(xdo id)" | grep 'WM_CLASS.*TmuxAlacritty' >/dev/null
}

is_vim() {
  tty=$(tmux display-message -p '#{pane_tty}')
  # shellcheck disable=2009
  ps -o state= -o comm= -t "$tty" | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'
}

has_pane_in_dir() {
  [ "$(tmux display-message -p "#{pane_at_$tmux_lookup_dir}")" -ne 1 ]
}

main
