# Enable ls colors by aliasing gnu coreutils ls – not needed when included in PATH
alias ls="gls --color=auto"

# Overrides l= "ls -lah"
alias l="ls -1"
alias ll="ls -l"
alias lll="ls -lah"

alias cl="clear"

# Folder managemant
# alias d='dirs -v'
# alias 1='pu'
# alias 2='pu -2'
# alias 3='pu -3'
# alias 4='pu -4'
# alias 5='pu -5'
# alias 6='pu -6'
# alias 7='pu -7'
# alias 8='pu -8'
# alias 9='pu -9'
# alias pu='() { pushd $1 &> /dev/null; dirs -v; }'
# alias po='() { popd &> /dev/null; dirs -v; }'

alias cdot="cd ~/.dotfiles"

alias cdd="cd ~/dev"
alias cdl="cd ~/learn"
alias cdb="cd ~/boilerplate"
alias cds="cd ~/sandbox"
alias cdck="cd ~/dev/code-is-king"

# Aliases for creating new CIK projects
alias npsht="sh newTypeScriptProject.sh"
alias npshj="sh newJavaProject.sh"
alias ns="sh ~/utilities/newSrcFile.sh"
alias nt="sh ~/utilities/newTestFile.sh"
alias nst="sh ~/utilities/newSrcAndTestFile.sh"

# Docker aliases
alias d="docker"
alias dk="docker container"
alias dkl="docker container ls"
alias dks="docker container start"
alias dkx="docker container stop"
alias di="docker image"
alias dil="docker image ls"
alias ds="docker service"
alias dsl="docker service ls"
alias dsp="docker service ps"
alias dv="docker volume"
alias dvl="docker volume ls"
alias dn="docker node"
alias dnl="docker node ls"

alias dc="docker-compose"

# VSCode
alias c="code"

# Script aliases
alias cs="complete-section"
alias fgc="find-git-changes"

# TODO: This is no longer true, but I could follow the link and reenable them.
# Git log aliases are found in: gitconfig
# cd /Library/Developer/CommandLineTools/usr/share/git-core/
# They are: lg, lg1, lg2, lg3
# Source: https://stackoverflow.com/questions/1838873/visualizing-branch-topology-in-git/34467298#34467298

alias git="nocorrect git"

alias reloadconfig="source $ZDOTDIR/.zshrc"

alias zshc="vim $ZDOTDIR/.zshrc"
alias vimc="vim $VIM_HOME/.vimrc"
alias tmuc="vim $TMUX_HOME/tmux.conf"
alias alac="vim $XDG_CONFIG_HOME/alacritty/alacritty.yml"

# There's basically just funky stuff in there...
# if [ "$(uname)" = "Darwin" ]; then
#   source ~/.local_zshconfig/*.zsh
# fi

