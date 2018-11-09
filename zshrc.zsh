# Many of these headers might be moved to separate files in the future.
# =============================================================================
#                                   Functions
# =============================================================================

function list_colors() {
  for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f";
}

function minp9k() {
  export DEFAULT_USER="elias.norrby";
  source ~/.dotfiles/powerlevel9k_minimal.zsh/ && reloadp9k;
}

function maxp9k() {
  export DEFAULT_USER="";
  source ~/.dotfiles/powerlevel9k_default.zsh/ && reloadp9k;
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
export ZSH="/Users/elias.norrby/.oh-my-zsh"

# =============================================================================
#                                   Plugins
# =============================================================================

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  docker
  mvn
  git
  git-flow
  git-flow-completion
  zsh-autosuggestions
  zsh-dircolors-solarized
  alias-tips
  #osx
  zsh-syntax-highlighting
)

# zsh-bd
. $HOME/.oh-my-zsh/custom/plugins/zsh-bd/bd.zsh

# =============================================================================
#                                   Themes
# =============================================================================

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
source ~/.dotfiles/powerlevel9k_common.zsh/
source ~/.dotfiles/powerlevel9k_default.zsh/
#source ~/.dotfiles/powerlevel9k_minimal.zsh/

# =============================================================================
#                                   Options
# =============================================================================

# User configuration
#DEFAULT_USER="elias.norrby"
DEFAULT_USER=""

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

source $ZSH/oh-my-zsh.sh

# Personal aliases
source ~/.zsh_aliases

