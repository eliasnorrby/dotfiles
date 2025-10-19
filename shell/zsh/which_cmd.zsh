# which-cmd integration for zsh

which-cmd() {
  ~/dev/which-cmd/target/debug/which-cmd "$@"
}

# command line variant
which_cmd_widget() {
    local result
    # The <$TTY part ensures that which-cmd reads input from the terminal ($TTY) rather than from
    #   the shell's standard input, which may not be connected to the terminal when running in a
    #   ZLE widget.
    <$TTY which-cmd build --border --immediate
    if [[ $? -eq 0 ]]; then
        result=$(which-cmd get)
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
bindkey '^P' which_cmd_widget

# tmux popup
which_cmd_tmux_widget() {
  if [[ $LBUFFER == "" ]]; then
    local result height
    height=$(~/dev/which-cmd/target/debug/which-cmd height)
    # TODO: Use proper path
    tmux display-popup -S fg=brightblack -T '#[fg=white bold] which-cmd #[fg=default]' -y P -w 95% -h $((height + 2)) -b rounded -EE "~/dev/which-cmd/target/debug/which-cmd build --immediate"
    result=$(~/dev/which-cmd/target/debug/which-cmd get)
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
