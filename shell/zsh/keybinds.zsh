# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=16
# This is not really specific to Vi mode though.
# bindkey -rpM viins '\e'
# Use the above to loose cursor keys in viins and make ESC independent of KEYTIMEOUT

# vi mode
bindkey -v

# surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround

# Autosuggestion key-bind
bindkey '^w' backward-kill-word
bindkey ',q' push-line
bindkey -M viins ',.' insert-last-word
bindkey -M viins '.,' insert-last-word
bindkey ',l' clear-screen

autoload -U is-at-least

# <5.0.8 doesn't have visual map
if is-at-least 5.0.8; then
  bindkey -M visual S add-surround

  # add vimmish text-object support to zsh
  autoload -U select-quoted; zle -N select-quoted
  for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
      bindkey -M $m $c select-quoted
    done
  done
  autoload -U select-bracketed; zle -N select-bracketed
  for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
      bindkey -M $m $c select-bracketed
    done
  done
fi

# Open current prompt in external editor
autoload -Uz edit-command-line; zle -N edit-command-line
bindkey -M vicmd 'V' edit-command-line

# Vim's C-x C-l in zsh
history-beginning-search-backward-then-append() {
  zle history-beginning-search-backward
  zle vi-add-eol
}
zle -N history-beginning-search-backward-then-append
bindkey -M viins '^x^x' history-beginning-search-backward-then-append
