# which-cmd integration for zsh

# command line variant
which_cmd_widget() {
    local result
    result=$(<$TTY ~/dev/which-cmd/target/debug/which-cmd)
    if [[ $? -eq 0 ]]; then
        LBUFFER+="$result"
    fi
    zle reset-prompt
}
zle -N which_cmd_widget
bindkey '^p' which_cmd_widget

# tmux popup
which_cmd_tmux_widget() {
  if [[ $LBUFFER == "" ]]; then
    local tempfile result
    tempfile=$(mktemp)
    # TODO: Use proper path
    tempfile=$tempfile tmux display-popup -T 'which-cmd' -y S -w 95% -h 20% -b rounded -E "~/dev/which-cmd/target/debug/which-cmd --immediate > $tempfile"
    result=$(<$tempfile)
    if [[ $result != "" ]]; then
      if [[ $result = __IMMEDIATE__* ]]; then
        local cmd
        cmd=$(echo $result | cut -d' ' -f2-)
        LBUFFER+="$cmd"
        zle accept-line
      else
        LBUFFER+="$result"
      fi
    fi
    zle reset-prompt
  else
    # See zsh/alias_expansion.zsh
    # TODO: Find a way to isolate these two widgets
    expand-alias-space
  fi
}
zle -N which_cmd_tmux_widget
bindkey ' ' which_cmd_tmux_widget
