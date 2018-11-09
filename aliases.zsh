# Enable ls colors by aliasing gnu coreutils ls – not needed when included in PATH
#alias ls="gls"
#alias dircolors="gdircolors"

alias ls="ls --color=auto"

# Overrides l= "ls -lah"
alias l="ls -1"

# Open zshconfig in Sublime Text
#alias zshconfig="open -a \"Sublime Text\" ~/.zshrc"
# With Sublime Text cli installed:
alias zshconfig="subl ~/.zshrc"
alias aconfig="subl ~/.zsh_aliases"

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
alias dk="docker"
alias ds="docker ps"
alias dks="docker start"
alias dkx="docker stop"
alias dkv="docker volume"

# Git log aliases are found in: gitconfig
# cd /Library/Developer/CommandLineTools/usr/share/git-core/
# 
# They are: lg, lg1, lg2, lg3
# Source: https://stackoverflow.com/questions/1838873/visualizing-branch-topology-in-git/34467298#34467298

alias git="nocorrect git"

alias reloadconfig="source ~/.zshrc"