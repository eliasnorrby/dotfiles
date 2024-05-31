if [[ "$(_os)" == "macos" ]]; then
  export GIT_SSH_COMMAND="/usr/bin/ssh -F ~/.ssh/macos.config"
fi
