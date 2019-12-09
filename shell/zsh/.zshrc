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
_load shell/zsh/config.zsh
_load shell/zsh/completion.zsh
_load shell/zsh/keybinds.zsh
_load shell/zsh/prompt.zsh
_load shell/zsh/fzf.zsh

if _remote; then
  # remote specifics
  _load shell/zsh/remote.zsh
else
  # local specifics
  _load shell/zsh/macos.zsh
fi

_load_all aliases.zsh

if [ -z "$TMUX" ] ; then
  tmux attach -t default || tmux new -s default
fi

# =============================================================================
#                              Experimenting
# =============================================================================
