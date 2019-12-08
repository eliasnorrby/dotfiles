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
# travis gem
[ -f /Users/elias.norrby/.travis/travis.sh ] && source /Users/elias.norrby/.travis/travis.sh

# TODO: move to :tmux: functions.zsh
function tn() {
  if [[ $# -eq 0 ]] ; then
      echo 'Error: must specify a session name'
      return 1
  fi
  tmux new-session -s "$1"
}


# =============================================================================
#                                   Variables
# =============================================================================

# tmux wants colors to be set or something...
export TERM="xterm-256color"

if [ "$(uname)" = "Darwin" ]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v '1.8*')"

  # For Ruby
  export PATH="/usr/local/opt/ruby/bin:$PATH"
  export PATH="/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"

  # For using GNU coreutils with default names
  # NTS: I use this for the 'tree' command
  export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

  export GOPATH=~/dev/go

  # FIXME: fix absolute path
  export PATH=/Users/elias.norrby/.emacs.d/bin:$PATH
  export PATH=/Users/elias.norrby/bin:$PATH
fi


# =============================================================================
#                                   Keybinds
# =============================================================================

# TODO: move to keybinds.zsh
bindkey -v
# Autosuggestion key-bind
bindkey -s '^[7' '|'
bindkey '^w' backward-kill-word
bindkey ',q' push-line
bindkey -M viins ',.' insert-last-word
bindkey -M viins '.,' insert-last-word
bindkey ',l' clear-screen

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=8



# =============================================================================
#                                   Options
# =============================================================================

# TODO: move to config.zsh
# User configuration
DEFAULT_USER="elias.norrby"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt auto_cd                  # Change directories without cd
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


alias ls="ls --color=auto"

# =============================================================================
#                                 Performance
# =============================================================================

# =============================================================================
#                                 Completions
# =============================================================================

# TODO: move to completion.zsh
fpath=(~/.zsh/completion $fpath)

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

# TODO: Find out why there are multiple compinit calls
# autoload -Uz compinit && compinit -i
# autoload -Uz compinit && compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit;
# else
#   compinit -C;
# fi;

# =============================================================================
#                                   Startup
# =============================================================================



# FIXME: fix absolute path
source ~/.dotfiles/shell/zsh/aliases.zsh

# =============================================================================
#                                   Plugins
# =============================================================================
# FIXME: fix absolute path
source ~/.dotfiles/shell/zsh/plugins.zsh

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

# Use fzf for z
alias j="_z 2>&1"
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# TODO: load with _load function when it's defined
# TODO: move to separate file and make sure to load late
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_COMMAND='fd --type f'
# export FZF_DEFAULT_COMMAND='rg --files --glob=!node_modules/*'
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
  --prompt "λ: "
  --color fg:7,bg:0,hl:3,fg+:15,bg+:0,hl+:4
  --color info:7,prompt:4,spinner:6,pointer:4,marker:4,gutter:0
'

source ~/.dotfiles/shell/zsh/fzf-functions.zsh

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

_load_all aliases.zsh

if [ -z "$TMUX" ] ; then
  tmux attach -t default || tmux new -s default
fi
