if [[ "$(_os)" == "macos" ]]; then
  source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
  source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
elif [[ "$(_os)" == "arch" ]]; then
  source /opt/google-cloud-sdk/completion.zsh.inc
fi
