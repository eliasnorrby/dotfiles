## Uncomment for performance stats
# zmodload zsh/zprof

# =============================================================================
#                                   Functions
# =============================================================================

if type brew &>/dev/null; then
  # Uncomment this if brew's location should change for some reason
  # FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# FIXME: fix absolute path
# travis gem completion
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# =============================================================================
#                                 Performance
# =============================================================================


# TODO: Find out why there are multiple compinit calls
# autoload -Uz compinit && compinit -i
# autoload -Uz compinit && compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit;
# else
#   compinit -C;
# fi;

# =============================================================================
#                                   Plugins
# =============================================================================
_load shell/zsh/plugins.zsh

dircolors_file=${ZPLUG_HOME}/repos/seebi/dircolors-solarized/dircolors.ansi-dark
if [ "$(uname)" = "Darwin" ] && [ -f $dircolors_file ] && command -v gdircolors > /dev/null ; then
  alias dircolors='gdircolors'
  eval $(gdircolors $dircolors_file)
fi

zplug load

# =============================================================================
#                             Post zplug load
# =============================================================================

zstyle :prompt:pure:path color yellow
zstyle :prompt:pure:git:dirty color yellow
zstyle :prompt:pure:prompt:success color cyan

# Set zsh autosuggestion text to a brighter color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# fzf
_load shell/zsh/fzf.zsh

# =============================================================================
#                              Session specific
# =============================================================================
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  # remote specifics
  # FIXME: fix relative path
  [ -f ~/.dotfiles/shell/zsh/remote.zsh ] && source ~/.dotfiles/shell/zsh/remote.zsh
else
  # local specifics
  [ -f ~/.dotfiles/shell/zsh/macos.zsh ] && source ~/.dotfiles/shell/zsh/macos.zsh
fi

# =============================================================================
#                                   Done
# =============================================================================

# =============================================================================
#                              Experimenting
# =============================================================================

# _load shell/zsh/prompt.zsh
_load shell/zsh/config.zsh
_load shell/zsh/completion.zsh
_load shell/zsh/keybinds.zsh

_load_all aliases.zsh

if [ -z "$TMUX" ] ; then
  tmux attach -t default || tmux new -s default
fi
