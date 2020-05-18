# source env file at root of dotfiles repo
# TODO: set path myself
unsetopt GLOBAL_RCS

# subshell-elimination: may not make a world of difference, but then again...
# source $(cd ${${(%):-%x}:A:h}/../.. && pwd -P)/env
source $HOME/.dotfiles/env

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZPLUG_HOME="$XDG_CACHE_HOME/zplug"
export ZSH_CACHE="$XDG_CACHE_HOME/zsh"

# paths
# Remove duplicates from $PATH (produced by refreshing config)
typeset -aU path
path=( $XDG_BIN_HOME $DOTFILES/bin $DOTFILES_DATA/*.topic/bin(N) $path )
# I don't understand this yet, so I'll keep it commented
# fpath=( $ZDOTDIR/functions $XDG_BIN_HOME $fpath )

# envvars
# export SHELL=$(command -v zsh)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PAGER=less
export LESS='-R -i -w -M -z-4'
export LESSHISTFILE="$XDG_DATA_HOME/lesshst"
export CLICOLOR=1

# I think this solves an issue with tmux colors
export TERM="xterm-256color"

if [[ "$(_os)" == "macos" ]]; then

  # For using GNU coreutils with default names
  # NTS: I use this for the 'tree' command
  # FIXME: No, appearently I don't. Is it for gnu ls?
  # FIXME: I need it to do readlink -f
  path=( /usr/local/opt/coreutils/libexec/gnubin $path )
  path=( /usr/local/mysql/bin $path )

  path=( ~/bin $path )
fi

# initialize enabled topics
_load_all env.zsh
