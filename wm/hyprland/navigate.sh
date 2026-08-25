#!/bin/sh

[ -z "$1" ] && echo "No dir specified" && exit 1

dir=$1
from_vim=$2

main() {
  map_dir "$dir"

  if ! is_tmux; then
    hyprland_select
    exit
  fi

  if [ -z "$from_vim" ] && is_vim; then
    vim_in_tmux_select
    exit 0
  fi

  if has_pane_in_dir; then
    tmux_select
  else
    hyprland_select
  fi
}

map_dir() {
  case $dir in
    l | left)  hypr_dir=l   tmux_select_dir=L   tmux_lookup_dir=left     vim_key=h   ;;
    r | right) hypr_dir=r   tmux_select_dir=R   tmux_lookup_dir=right    vim_key=l   ;;
    u | up)    hypr_dir=u   tmux_select_dir=U   tmux_lookup_dir=top      vim_key=k   ;;
    d | down)  hypr_dir=d   tmux_select_dir=D   tmux_lookup_dir=bottom   vim_key=j   ;;
    *)
      echo "Invalid dir: $dir"
      exit 1
      ;;
  esac
}

# Signature of the compositor the *current* tmux client belongs to. tmux
# refreshes this per session on attach via `update-environment`, so a local
# Hyprland terminal exports it while an ssh/mosh client marks it unset —
# which makes it a reliable "is this client local?" test.
#
# Read the value out rather than eval'ing the session environment into this
# shell: the eval applies the `unset` too, which cleared the ambient
# signature and left every hyprctl call below failing when attached remotely.
signature_filter='s/^HYPRLAND_INSTANCE_SIGNATURE="\(.*\)"; export.*/\1/p'

client_hyprland_signature() {
  tmux show-environment -s 2>/dev/null | sed -n "$signature_filter"
}

hyprland_select() {
  # From inside tmux, only hand focus over to the compositor when the attached
  # client is a local Hyprland terminal. Over ssh/mosh there is no window to
  # move to, and dispatching would shift focus on the workstation's physical
  # display instead. Prefer the client's signature over the ambient one, which
  # goes stale if Hyprland restarted after the tmux server started.
  if [ -n "$TMUX" ]; then
    signature=$(client_hyprland_signature)
    [ -z "$signature" ] && return 0
    HYPRLAND_INSTANCE_SIGNATURE=$signature
    export HYPRLAND_INSTANCE_SIGNATURE
  fi

  hyprctl dispatch movefocus $hypr_dir
}

tmux_select() {
  tmux select-pane "-${tmux_select_dir}"
}

vim_in_tmux_select() {
  tmux send-keys "C-${vim_key}"
}

is_tmux() {
  # Running inside a tmux pane (from vim, or a tmux binding) settles it, and
  # unlike the compositor check below it holds over ssh/mosh too.
  [ -n "$TMUX" ] && return 0

  # Invoked from a Hyprland keybind instead, so the compositor spawned us and
  # its signature is already in the environment. Ask what currently has focus.
  active_class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class' 2>/dev/null)
  echo "$active_class" | grep -qE 'Tmux(Alacritty|Kitty)'
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
