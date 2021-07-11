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

# disable flow control (unbind ^S)
stty -ixon 2>/dev/null

unsetopt BEEP                   # Turn off all beeps
# unsetopt LIST_BEEP            # Turn off autocomplete beeps

# setup up colors for ls
dircolors_file=${ZPLUG_HOME}/repos/seebi/dircolors-solarized/dircolors.ansi-dark
if [[ $(_os) == macos ]] && [ -f $dircolors_file ] && _is_callable gdircolors > /dev/null ; then
  alias dircolors='gdircolors'
  eval $(gdircolors $dircolors_file)
fi
