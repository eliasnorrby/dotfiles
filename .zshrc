# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export JAVA_HOME=/Library/Java/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-10.0.2.jdk
# export JAVA_HOME="$(/usr/libexec/java_home)"
export JAVA_HOME="$(/usr/libexec/java_home -v '1.8*')"

# For using GNU coreutils with default names
# NTS: I use this for the 'tree' command
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

# Remove duplicates from $PATH (produced by running 'zsh' to refresh config)
typeset -aU path

export LANG=en_US.UTF-8


# Path to your oh-my-zsh installation.
export ZSH="/Users/elias.norrby/.oh-my-zsh"

## AGNOSTER
#ZSH_THEME="agnoster"

# --------------------------------------
## POWERLEVEL9K
# --------------------------------------
# Most of these settings are copied from https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config#hacckss-config
# His comments have doucle dashes (##)

ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true


#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%{%F{249}%}\u250f"
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%F{249}%}\u2517%{%F{default}%} ❯ "
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="❯ "

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="╭"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="╰\uF460 "
# For awesome inivisibleness, set iterm background color to '003340'

#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{cyan}\u256D\u2500%f"
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{014}\u2570%F{cyan}\uF460%F{073}\uF460%F{109}\uF460%f "
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="╭─%f"
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="╰─%F{008}\uF460 %f"
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{008}> %f"

#POWERLEVEL9K_OS_ICON_BACKGROUND="none"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon user dir_writable dir vcs)
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir_writable dir vcs)
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir_writable dir)

#POWERLEVEL9K_TIME_ICON=""
#POWERLEVEL9K_TIME_BACKGROUND="249"
POWERLEVEL9K_DISABLE_RPROMPT=false
# Basic elements
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator time load ram battery)


# Advanced metrics (slow :( )
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator background_jobs time disk_usage ram battery)


POWERLEVEL9K_BATTERY_VERBOSE=false

##POWERLEVEL9K_USER_ICON="\uF415" # 
POWERLEVEL9K_ROOT_ICON="\uF09C"
##POWERLEVEL9K_SUDO_ICON=$'\uF09C' # 
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
##POWERLEVEL9K_VCS_GIT_ICON='\uF408 '
##POWERLEVEL9K_VCS_GIT_GITHUB_ICON='\uF408 '

POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
#POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_from_right
POWERLEVEL9K_SHORTEN_DELIMITER=""

POWERLEVEL9K_VCS_SHORTEN_LENGTH=12
POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=25
POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_VCS_SHORTEN_DELIMITER="..."

## I might want to override these icons...
#VCS_GIT_GITHUB_ICON=
#VCS_GIT_BITBUCKET_ICON=
#VCS_GIT_GITLAB_ICON=
#VCS_GIT_ICON=

#ZSH_DISABLE_COMPFIX=true

# This is nice, but leads to bugs with cursor jumping about when using tab completion and multiline prompt
#COMPLETION_WAITING_DOTS="true"
# --------------------------------------

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"
# Before trying to enable colors: LSCOLORS=Gxfxcxdxbxegedabagacad

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
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
  #shrink-path
  zsh-syntax-highlighting
)

# zsh-bd
. $HOME/.oh-my-zsh/custom/plugins/zsh-bd/bd.zsh

# Shrink paths
#prompt_dir() {
#    prompt_segment blue black "%-53<...<%~%<<"
#}

# When using the agnoster theme, paths are shrunken using this approach:
# - Open this directory ~/.oh-my-zsh/themes
# - Open the agnoster.zsh-theme file with any text editor
# - Go to the prompt_dir() function
# - Replace the line in the function with this: prompt_segment blue black '%c'

# Autosuggestion key-bind
bindkey '^ ' autosuggest-accept

source $ZSH/oh-my-zsh.sh

# User configuration
#DEFAULT_USER="elias.norrby"
DEFAULT_USER=""

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Personal aliases
source ~/.zsh_aliases
alias aconfig="subl ~/.zsh_aliases"

### ALL ALIASES HAVE BEEN MOVED TO THE FILE REFERENCED ABOVE
# # Enable ls colors by aliasing gnu coreutils ls – not needed when included in PATH
# #alias ls="gls"
# #alias dircolors="gdircolors"
# 
# alias ls="ls --color=auto"
# 
# # Overrides l= "ls -lah"
# alias l="ls -1"
# 
# # Open zshconfig in Sublime Text
# alias zshconfig="open -a \"Sublime Text\" ~/.zshrc"
# # With Sublime Text cli installed:
# #alias zshconfig="subl ~/.zshrc"
# 
# # Navigate to root private folder in FFCG Dropbox
# alias cdh="cd ~/Dropbox\ \(FFCG\)/folders" 
# 
# alias cdd="cd ~/Dropbox\ \(FFCG\)/folders/dev"
# 
# alias cdck="cd ~/Dropbox\ \(FFCG\)/folders/dev/CodeIsKing" 
# 
# alias npsh="sh newProject.sh"
# 
# alias ns="sh ~/utilities/newSrcFile.sh"
# 
# alias nt="sh ~/utilities/newTestFile.sh"
# 
# alias nst="sh ~/utilities/newSrcAndTestFile.sh"
# 
# # Git aliases are found in: gitconfig
# # cd /Library/Developer/CommandLineTools/usr/share/git-core/
# # 
# # They are: lg, lg1, lg2, lg3
# Source: https://stackoverflow.com/# questions/1838873/visualizing-branch-topology-in-git/34467298#34467298
