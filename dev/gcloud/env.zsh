if [[ "$(_os)" == "macos" ]]; then
  source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
elif [[ "$(_os)" == "arch" ]]; then
  source /opt/google-cloud-sdk/completion.zsh.inc
fi
