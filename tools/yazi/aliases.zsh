# sets up zoxide (z)
eval "$(zoxide init zsh)"

if type projects >/dev/null 2>&1; then
  z() {
    if [[ -n "$1" ]]; then
      __zoxide_z "$@"
    else
      projects
    fi
  }
fi

alias y="yazi"
