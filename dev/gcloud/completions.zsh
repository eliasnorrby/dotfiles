if [[ "$(_os)" == "macos" ]]; then
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
  source "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
elif [[ "$(_os)" == "arch" ]]; then
  source /opt/google-cloud-cli/completion.zsh.inc
fi
