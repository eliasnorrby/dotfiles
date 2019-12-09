# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=8

# vi mode
bindkey -v

# Autosuggestion key-bind
bindkey '^w' backward-kill-word
bindkey ',q' push-line
bindkey -M viins ',.' insert-last-word
bindkey -M viins '.,' insert-last-word
bindkey ',l' clear-screen

# Vim's C-x C-l in zsh
history-beginning-search-backward-then-append() {
  zle history-beginning-search-backward
  zle vi-add-eol
}
zle -N history-beginning-search-backward-then-append
bindkey -M viins '^x^l' history-beginning-search-backward-then-append
