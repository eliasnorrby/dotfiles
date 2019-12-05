# source env file at root of dotfiles repo
# TODO: set path myself
# unsetopt GLOBAL_RCS

source $(cd ${${(%):-%x}:A:h}/../.. && pwd -P)/env

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
# TODO I don't dare doing this yet
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
export GREP_OPTIONS='--color=always'

# initialize enabled topics
_load_all env.zsh
