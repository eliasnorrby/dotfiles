fpath=( ~/.zsh/completion $fpath )

# Enable completion for homebrew packages
if type brew &>/dev/null; then
  # Uncomment this if brew's location should change for some reason
  # FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  fpath=( /usr/local/share/zsh/site-functions $fpath )
fi

# travis gem completion
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# case-insensitive (all), partial-word and then substring completion
zstyle ":completion:*" matcher-list \
  "m:{a-zA-Z}={A-Za-z}" \
  "r:|[._-]=* r:|=*" \
  "l:|=* r:|=*"

zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# Enable approximate completions
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3)) numeric)'

# Keep directories and files separated
zstyle ':completion:*' list-dirs-first true

autoload -Uz compinit && compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit;
# else
#   compinit -C;
# fi;

