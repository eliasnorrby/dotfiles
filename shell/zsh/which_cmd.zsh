# which-cmd integration for zsh

# command line variant
which_cmd_widget() {
    local result
    # The <$TTY part ensures that wcmd reads input from the terminal ($TTY) rather than from
    #   the shell's standard input, which may not be connected to the terminal when running in a
    #   ZLE widget.
    <$TTY wcmd build --border --immediate
    if [[ $? -eq 0 ]]; then
        result=$(wcmd get)
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
    fi
    zle reset-prompt
}
zle -N which_cmd_widget
bindkey '^U' which_cmd_widget

# tmux popup
which_cmd_tmux_widget() {
  if [[ $LBUFFER == "" ]]; then
    if ! [[ -n $TMUX ]]; then
      zle which_cmd_widget
      return
    fi
    local result height=10
    # TODO: Use proper path
    tmux display-popup \
      -S fg=brightblack \
      -T '#[fg=white bold] wcmd #[fg=default]' \
      -y P -w 95% -h $((height + 2)) -b rounded \
      -EE "wcmd build --immediate --height ${height}"
    result=$(wcmd get)
    if [[ $result != "" ]]; then
      if [[ $result = __IMMEDIATE__* ]]; then
        local cmd
        cmd=$(echo $result | cut -d' ' -f2-)
        LBUFFER+="$cmd"
        zle accept-line
      else
        LBUFFER+="$result"
        zle self-insert
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
