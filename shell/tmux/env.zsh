export TMUX_HOME="$XDG_CONFIG_HOME/tmux"

if [[ "$(_os)" == "macos" ]] ; then
  tmux_copy () {
    pbcopy
  }
else
  tmux_copy () {
    xclip -selection clipboard
  }
fi
