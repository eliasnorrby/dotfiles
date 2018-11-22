## Uncomment for performance stats
#zmodload zsh/zprof

# Many of these headers might be moved to separate files in the future.
# =============================================================================
#                                   Functions
# =============================================================================

function list_colors() {
  for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f";
}

function minp9k() {
  export DEFAULT_USER="elias.norrby";
  source ~/.dotfiles/powerlevel9k_minimal.zsh && reloadp9k;
}

function maxp9k() {
  export DEFAULT_USER="";
  source ~/.dotfiles/powerlevel9k_default.zsh && reloadp9k;
}

function reloadp9k() {
  prompt_powerlevel9k_teardown && prompt_powerlevel9k_setup;
}

# =============================================================================
#                                   Variables
# =============================================================================

export JAVA_HOME="$(/usr/libexec/java_home -v '1.8*')"

# For using GNU coreutils with default names
# NTS: I use this for the 'tree' command
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

# Remove duplicates from $PATH (produced by running 'zsh' to refresh config)
typeset -aU path

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Path to your oh-my-zsh installation.
#export ZSH="/Users/elias.norrby/.oh-my-zsh"

# =============================================================================
#                                   Plugins
# =============================================================================

# [ ! -d ~/.zplug ] && git clone https://github.com/zplug/zplug ~/.zplug
# source ~/.zplug/init.zsh

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Miscellaneous
zplug "k4rthik/git-cal",  as:command
#zplug "peco/peco",        as:command, from:gh-r
#zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf, \
#  use:"*${(L)$(uname -s)}*amd64*"
#zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#
#
## Enhanced cd
zplug "b4b4r07/enhancd", use:init.sh

# Enhanced dir list with git features
zplug "supercrabtree/k"

# Jump back to parent directory
zplug "tarrasch/zsh-bd"

# Directory colors
zplug "seebi/dircolors-solarized", ignore:"*", as:plugin

## Check these out later
#zplug "plugins/common-aliases",    from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
##zplug "plugins/colorize",          from:oh-my-zsh
#zplug "plugins/command-not-found", from:oh-my-zsh
#zplug "plugins/copydir",           from:oh-my-zsh
#zplug "plugins/copyfile",          from:oh-my-zsh
#zplug "plugins/cp",                from:oh-my-zsh
#zplug "plugins/dircycle",          from:oh-my-zsh
#zplug "plugins/encode64",          from:oh-my-zsh
#zplug "plugins/extract",           from:oh-my-zsh
#zplug "plugins/history",           from:oh-my-zsh
#zplug "plugins/tmux",              from:oh-my-zsh
#zplug "plugins/tmuxinator",        from:oh-my-zsh
#zplug "plugins/urltools",          from:oh-my-zsh
#zplug "plugins/web-search",        from:oh-my-zsh
zplug "plugins/z",                 from:oh-my-zsh
#zplug "plugins/fancy-ctrl-z",      from:oh-my-zsh

if [[ $OSTYPE = (darwin)* ]]; then
    zplug "lib/clipboard",         from:oh-my-zsh
    #zplug "plugins/osx",           from:oh-my-zsh
    zplug "plugins/brew",          from:oh-my-zsh, if:"(( $+commands[brew] ))"
    #zplug "plugins/macports",      from:oh-my-zsh, if:"(( $+commands[port] ))"
fi

zplug "bobthecow/git-flow-completion", if:"(( $+commands[git] ))"
zplug "plugins/git",               from:oh-my-zsh, if:"(( $+commands[git] ))"
zplug "plugins/git-flow",          from:oh-my-zsh, if:"(( $+commands[git] ))"
#zplug "plugins/golang",            from:oh-my-zsh, if:"(( $+commands[go] ))"
#zplug "plugins/svn",               from:oh-my-zsh, if:"(( $+commands[svn] ))"
#zplug "plugins/node",              from:oh-my-zsh, if:"(( $+commands[node] ))"
#zplug "plugins/npm",               from:oh-my-zsh, if:"(( $+commands[npm] ))"
#zplug "plugins/bundler",           from:oh-my-zsh, if:"(( $+commands[bundler] ))"
#zplug "plugins/gem",               from:oh-my-zsh, if:"(( $+commands[gem] ))"
#zplug "plugins/rbenv",             from:oh-my-zsh, if:"(( $+commands[rbenv] ))"
#zplug "plugins/rvm",               from:oh-my-zsh, if:"(( $+commands[rvm] ))"
#zplug "plugins/pip",               from:oh-my-zsh, if:"(( $+commands[pip] ))"
#zplug "plugins/sudo",              from:oh-my-zsh, if:"(( $+commands[sudo] ))"
#zplug "plugins/gpg-agent",         from:oh-my-zsh, if:"(( $+commands[gpg-agent] ))"
#zplug "plugins/systemd",           from:oh-my-zsh, if:"(( $+commands[systemctl] ))"
# zplug "plugins/docker",            from:oh-my-zsh, if:"(( $+commands[docker] ))"
# zplug "plugins/docker-compose",    from:oh-my-zsh, if:"(( $+commands[docker-compose] ))"
zplug "plugins/mvn",               from:oh-my-zsh, if:"(( $+commands[mvn] ))"

zplug "djui/alias-tips"
#zplug "hlissner/zsh-autopair", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
# zsh-syntax-highlighting must be loaded after executing compinit command
# and sourcing other plugins
zplug "zsh-users/zsh-syntax-highlighting", defer:2
#zplug "zsh-users/zsh-history-substring-search", defer:3

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(
  #docker
  #mvn
  #git
  #git-flow
  #git-flow-completion
  #zsh-autosuggestions
  #zsh-dircolors-solarized
  #alias-tips
  #osx
  #zsh-syntax-highlighting
#)

# zsh-bd
# . $HOME/.oh-my-zsh/custom/plugins/zsh-bd/bd.zsh

# =============================================================================
#                                   Themes
# =============================================================================

# tmux wants colors to be set or something...
export TERM="xterm-256color"

# ----------------------------------------
# Agnoster
# ----------------------------------------
#ZSH_THEME="agnoster"

# When using the agnoster theme, paths are shrunken using this approach:
# - Open this directory ~/.oh-my-zsh/themes
# - Open the agnoster.zsh-theme file with any text editor
# - Go to the prompt_dir() function
# - Replace the line in the function with this: prompt_segment blue black '%c'

# ----------------------------------------
# Powerlevel9k
# ----------------------------------------
# Always load common config, uncomment variation

# Load theme using oh-my-zsh
#ZSH_THEME="powerlevel9k/powerlevel9k"

# Load theme using zplug
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
source ~/.dotfiles/powerlevel9k_common.zsh
source ~/.dotfiles/powerlevel9k_default.zsh
#source ~/.dotfiles/powerlevel9k_minimal.zsh

# =============================================================================
#                                   Options
# =============================================================================

# User configuration
DEFAULT_USER="elias.norrby"
# DEFAULT_USER=""

# improved less option
#export LESS="--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# NTS: This is nice, but leads to bugs with cursor jumping about when using tab completion and multiline prompt
# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Autosuggestion key-bind
bindkey '^ ' autosuggest-accept

# source $ZSH/oh-my-zsh.sh

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt autocd                   # Allow changing directories without `cd`
setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.
setopt hist_ignore_space        # Ignore commands that start with space.

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --reverse --extended --border --inline-info --color=dark,bg+:235,hl+:10,pointer:5'
# export FZF_DEFAULT_OPTS='
#   --height 40% --reverse --border --inline-info 
#   --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254
#   --color info:254,prompt:37,spinner:108,pointer:235,marker:235
# '

export ENHANCD_FILTER="fzy:fzf:peco:percol"
export ENHANCD_COMMAND='c'

# Directory coloring
#if [[ $OSTYPE = (darwin|freebsd)* ]]; then
#  export CLICOLOR="YES" # Equivalent to passing -G to ls.
#  export LSCOLORS="exgxdHdHcxaHaHhBhDeaec"
#
#  [ -d "/opt/local/bin" ] && export PATH="/opt/local/bin:$PATH"
#
#  # Prefer GNU version, since it respects dircolors.
#  if (( $+commands[gls] )); then
#    alias ls='() { $(whence -p gls) -Ctr --file-type --color=auto $@ }'
#  else
#    alias ls='() { $(whence -p ls) -CFtr $@ }'
#  fi
#else
#  alias ls='() { $(whence -p ls) -Ctr --file-type --color=auto $@ }'
#fi

alias ls="ls --color=auto"

# =============================================================================
#                                 Performance
# =============================================================================

if [[ 1 == 2 ]] ; then
  #DISABLE_UNTRACKED_FILES_DIRTY="true"
  # Default:
  #POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname)
  #POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-aheadbehind git-remotebranch git-tagname)
  POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes)
fi

# =============================================================================
#                                 Completions
# =============================================================================

fpath=(~/.zsh/completion $fpath)

zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose yes
#zstyle ':completion:*:descriptions' format '%B%d%b'
#zstyle ':completion:*:messages' format '%d'
#zstyle ':completion:*:warnings' format 'No matches for: %d'
#zstyle ':completion:*' group-name ''

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

autoload -Uz compinit && compinit -i
# =============================================================================
#                                   Startup
# =============================================================================

## Adds ~0.3 seconds to startup time
# Install plugins if there are plugins that have not been installed
# if ! zplug check; then
#     printf "Install plugins? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi

if zplug check "seebi/dircolors-solarized"; then
  which gdircolors &> /dev/null && alias dircolors='gdircolors'
  which dircolors &> /dev/null && \
    eval `dircolors /usr/local/opt/zplug/repos/seebi/dircolors-solarized/dircolors.ansi-dark`
fi
# eval `gdircolors /usr/local/opt/zplug/repos/seebi/dircolors-solarized/dircolors.ansi-dark`

# Personal aliases
source ~/.zsh_aliases


zplug load

alias j="_z 2>&1"
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# fd - cd to selected directory
fdd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# c - browse chrome history
chrome() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}
