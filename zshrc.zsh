## Uncomment for performance stats
#zmodload zsh/zprof

# Many of these headers might be moved to separate files in the future.
# =============================================================================
#                                   Functions
# =============================================================================

# === Config ===

function zup() {
  source ~/.zsh_plugins
}

function minp9k() {
  export DEFAULT_USER="$USER";
  source ~/.dotfiles/powerlevel9k_minimal.zsh && reloadp9k;
}

function maxp9k() {
  export DEFAULT_USER="";
  source ~/.dotfiles/powerlevel9k_default.zsh && reloadp9k;
}

function reloadp9k() {
  prompt_powerlevel9k_teardown && prompt_powerlevel9k_setup;
}

function toggleMultilinePrompt() {
  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" = true ]] ; then
    POWERLEVEL9K_PROMPT_ON_NEWLINE=false
    POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  elif [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" = false ]] ; then
    POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  fi
}

# === Utilities ===

function tkey() {
  grep "$1" ~/.dotfiles/tmux-cheatsheet.md
}

function tkeydocs() {
  vim ~/.dotfiles/tmux-cheatsheet.md
}

function mkd() {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

function list_colors() {
  for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f";
}

function ls_dirs_files() {
  echo "-> Directories:"
  colorls --dirs -l -1
  echo ""
  echo "-> Files:"
  colorls --files -l -1
}


# =============================================================================
#                                   Variables
# =============================================================================

if [ "$(uname)" = "Darwin" ]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v '1.8*')"

  # For Ruby
  export PATH="/usr/local/opt/ruby/bin:$PATH"
  export PATH="/usr/local/lib/ruby/gems/2.5.0/bin:$PATH"

  # For using GNU coreutils with default names
  # NTS: I use this for the 'tree' command
  export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
fi

# Remove duplicates from $PATH (produced by running 'zsh' to refresh config)
typeset -aU path

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Path to your oh-my-zsh installation.
#export ZSH="/Users/elias.norrby/.oh-my-zsh"

# =============================================================================
#                                   Keybinds
# =============================================================================

bindkey -v
# Autosuggestion key-bind
bindkey '^ ' autosuggest-accept
bindkey 'jk' vi-cmd-mode
# Unbind esc key - why do I wan't that..?
bindkey -s '^[7' '|'
#bindkey '^[[1;9C' forward-word
#bindkey '^[[1;9D' backward-word
bindkey '^w' backward-kill-word
bindkey ',q' push-line
bindkey -M viins ',.' insert-last-word
bindkey -M viins '.,' insert-last-word
bindkey ',l' clear-screen

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=8


# =============================================================================
#                                   Plugins
# =============================================================================

if [ "$(uname)" = "Darwin" ]; then
  export ZPLUG_HOME=/usr/local/opt/zplug
fi
if [ "$(uname)" = "Linux" ]; then
  export ZPLUG_HOME=~/.zplug
fi
source $ZPLUG_HOME/init.zsh

# zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Miscellaneous
zplug "k4rthik/git-cal",  as:command

# Enhanced dir list with git features
zplug "supercrabtree/k" 

if [ "$(uname)" = "Darwin" ]; then
  # Directory colors
  zplug "seebi/dircolors-solarized", ignore:"*", as:plugin
fi

# Jump back to parent directory
zplug "tarrasch/zsh-bd"

# Directory colors
# zplug "seebi/dircolors-solarized", ignore:"*", as:plugin

zplug "plugins/z",                 from:oh-my-zsh

zplug "plugins/git",               from:oh-my-zsh
zplug "plugins/git-flow",          from:oh-my-zsh

zplug "zsh-users/zsh-autosuggestions"
# zsh-syntax-highlighting must be loaded after executing compinit command
# and sourcing other plugins
zplug "zsh-users/zsh-syntax-highlighting", defer:2

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
if [ "$(uname)" = "Darwin" ]; then
  source ~/.dotfiles/powerlevel9k_default.zsh
  #source ~/.dotfiles/powerlevel9k_minimal.zsh
fi
if [ "$(uname)" = "Linux" ]; then
  source ~/.dotfiles/powerlevel9k_server.zsh
fi

# =============================================================================
#                                   Options
# =============================================================================

# User configuration
# DEFAULT_USER="elias.norrby"
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
COMPLETION_WAITING_DOTS="true"


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


# unsetopt BEEP                 # Turn off all beeps
unsetopt LIST_BEEP              # Turn off autocomplete beeps 

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --reverse --extended --border --inline-info --color=dark,bg+:235,hl+:10,pointer:5'
# export FZF_DEFAULT_OPTS='
#   --height 40% --reverse --border --inline-info 
#   --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254
#   --color info:254,prompt:37,spinner:108,pointer:235,marker:235
# '

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

# zstyle ':completion:*' rehash true
# zstyle ':completion:*' verbose yes
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

# autoload -Uz compinit && compinit -i
autoload -Uz compinit && compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit;
# else
#   compinit -C;
# fi;

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

if [ "$(uname)" = "Darwin" ]; then
  alias dircolors='gdircolors'
  eval `gdircolors /usr/local/opt/zplug/repos/seebi/dircolors-solarized/dircolors.ansi-dark`
fi
# Personal aliases
source ~/.zsh_aliases

zplug load

alias j="_z 2>&1"
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# =============================================================================
#                              Session specific
# =============================================================================
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  # remote specifics
else
  # local specifics
  # chrome - browse chrome history
  function chrome() {
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

  # search in lynx
  # Opens a lynx browser searching any terms that follow the name of this script
  function test_search() {
    url="https://www.google.com/search?q="

    for term in "$@"
    do
      url=$url"+"$term
    done

    lynx -accept_all_cookies $url
  }

  function cool_echo() {
    artii --font slant "$1" | lolcat
  }
fi

# =============================================================================
#                                   Done
# =============================================================================
# artii ">> Up and running <<" --font slant | lolcat
cd ~/.dotfiles
branch_string=$(git branch | grep \* | cut -d ' ' -f2)
commit_message=$(git log -1 --no-merges --pretty=%B)
cd
echo ".dotfiles branch: $branch_string"
echo "latest commit: $commit_message"
echo 
