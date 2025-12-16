#!/bin/sh

[ -z "$TMUX" ] && exit

[ -z "$1" ] && echo "No dir specified" && exit 1

dir=$1

map_dir() {
  case $dir in
    l|left)  tmux_select_dir=L ;;
    r|right) tmux_select_dir=R ;;
    u|up)    tmux_select_dir=U ;;
    d|down)  tmux_select_dir=D ;;
    *)
      echo "Invalid dir: $dir"
      exit 1
      ;;
  esac
}

map_dir

tmux select-pane "-${tmux_select_dir}"
