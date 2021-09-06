alias rl="exec zsh"

balias clh="curl -sS localhost:"

# global aliases
alias -g G="| grep"
alias -g X="| xargs"
alias -g Xi="| xargs -I{}"
alias -g L="| less"
alias -g H="-h | less"
alias -g Y="| yq"
alias -g J="| jq"
alias -g E="| entr"
alias -g EE="| entr /_"
alias -g C="| copy_cmd"
alias -g B="| base64"
alias -g Bd="| base64 -d"

if [[ "$(_os)" == "macos" ]] ; then
  # Enable ls colors by aliasing gnu coreutils ls – not needed when included in PATH
  ialias ls="gls --color=auto --human-readable --group-directories-first"
else
  ialias ls="ls --color=auto --human-readable --group-directories-first"
fi

# Overrides l= "ls -lah"
alias l="ls -1"
alias ll="ls -l"
alias lll="ls -lah"

alias cl="clear"

# For example, to list all directories that contain a certain file: find . -name
# .gitattributes | map dirname
alias map="xargs -n1"

alias myip="curl -s api.ipify.org"

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
alias cdw="cd ~/work"
alias cdl="cd ~/learn"
alias cds="cd ~/sandbox"
alias cdf="cd ~/forks"

# Script aliases
alias cs="complete-section"
alias fgc="find-git-changes"

if [[ "$(_os)" == "macos" ]] ; then
  alias sudoedit="sudo -e"
fi

alias chx="chmod +x"

ns() {
  touch "$1"
  chmod +x "$1"
}

cdt() {
  cd "$(mktemp -d)"
}

cdg() {
  if !  git rev-parse HEAD > /dev/null 2>&1; then
    echo "Not in a git repository"
    return 1
  fi

  cd "$(git rev-parse --show-toplevel)"
}
