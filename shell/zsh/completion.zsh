fpath=( ~/.zsh/completion $fpath )

# Enable completion for homebrew packages
if type brew &>/dev/null; then
  fpath=( $HOMEBREW_PREFIX/share/zsh/site-functions $fpath )
fi

# tabtab source for packages (pnpm)
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
# tabtab source for packages (netlify)
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

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

# FIXME: get this to work for once
# setopt extendedglob
# if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]] || [[ ! -f ${ZDOTDIR}/.zcompdump ]]; then
#   compinit
# else
#   compinit -C
# fi
# unsetopt extendedglob
