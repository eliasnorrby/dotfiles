# Enable ls colors by aliasing gnu coreutils ls – not needed when included in PATH
#alias ls="gls"
#alias dircolors="gdircolors"

# Generic command adaptations
alias grep='() { $(whence -p grep) --color=auto $@ }'
alias egrep='() { $(whence -p egrep) --color=auto $@ }'

# Overrides l= "ls -lah"
alias l="ls -1"

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

# Open zshconfig in Sublime Text
# alias zshconfig="open -a \"Sublime Text\" ~/.zshrc"
# With Sublime Text cli installed:
# alias zshconfig="subl ~/.zshrc"
alias zshconfig="subl ~/.dotfiles/zshrc.zsh"
# alias aconfig="subl ~/.zsh_aliases"
alias aconfig="subl ~/.dotfiles/aliases.zsh"
alias vimconfig="vim ~/.dotfiles/vimrc.vim"
alias termconfig="sh ~/scripts/term-config.sh"
alias allconfig="subl ~/.dotfiles"

# Navigate to root private folder in FFCG Dropbox
alias cdh="cd ~/Dropbox\ \(FFCG\)/folders" 

alias cdd="cd ~/Dropbox\ \(FFCG\)/folders/dev"

alias cdck="cd ~/Dropbox\ \(FFCG\)/folders/dev/CodeIsKing" 

# Aliases for creating new CIK projects
alias npsht="sh newTypeScriptProject.sh"
alias npshj="sh newJavaProject.sh"
alias ns="sh ~/utilities/newSrcFile.sh"
alias nt="sh ~/utilities/newTestFile.sh"
alias nst="sh ~/utilities/newSrcAndTestFile.sh"

# Docker aliases
alias d="docker"
alias dc="docker container"
alias dcl="docker container ls"
alias dcs="docker container start"
alias dcx="docker container stop"
alias di="docker image"
alias dil="docker image ls"
alias ds="docker service"
alias dsl="docker service ls"
alias dsp="docker service ps"
alias dv="docker volume"
alias dvl="docker volume ls"
alias dn="docker node"
alias dnl="docker node ls"


# Git log aliases are found in: gitconfig
# cd /Library/Developer/CommandLineTools/usr/share/git-core/
# 
# They are: lg, lg1, lg2, lg3
# Source: https://stackoverflow.com/questions/1838873/visualizing-branch-topology-in-git/34467298#34467298

alias git="nocorrect git"

alias reloadconfig="source ~/.zshrc"
