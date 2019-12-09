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

# VSCode
alias c="code"

# Script aliases
alias cs="complete-section"
alias fgc="find-git-changes"

alias zshc="vim $ZDOTDIR/.zshrc"

