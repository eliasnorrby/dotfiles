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

alias m="make"

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
alias ipc="myip | copy_cmd"

alias cdot="cd ~/.dotfiles"

alias cdd="cd ~/dev"
alias cdw="cd ~/work"
alias cdl="cd ~/learn"
alias cds="cd ~/sandbox"
alias cdf="cd ~/forks"

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
