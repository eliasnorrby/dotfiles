# =============================================================================
#                                 Performance
# =============================================================================

## Uncomment for performance stats
# zmodload zsh/zprof

# TODO: Find out why there are multiple compinit calls
# autoload -Uz compinit && compinit -i
# autoload -Uz compinit && compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit;
# else
#   compinit -C;
# fi;

# =============================================================================
#                                Load all the things
# =============================================================================
_load shell/zsh/config.zsh
_load shell/zsh/completion.zsh
_load shell/zsh/keybinds.zsh
_load shell/zsh/prompt.zsh
_load shell/zsh/plugins.zsh
_load shell/zsh/fzf.zsh

zplug load

if _remote ; then
  _load shell/zsh/remote.zsh
else
  _load shell/zsh/macos.zsh
fi

_load_all aliases.zsh

if [ -z "$TMUX" ] ; then
  tmux attach -t default || tmux new -s default
fi

# =============================================================================
#                              Experimenting
# =============================================================================
