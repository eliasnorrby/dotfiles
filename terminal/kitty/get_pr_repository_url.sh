#!/usr/bin/env bash

# Update path if we're on macOS
HOMEBREW_ENV_FILE="$HOME/.homebrew"
if [[ -f "$HOMEBREW_ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  . "$HOMEBREW_ENV_FILE"
fi

directory=$("${XDG_BIN_HOME:-$HOME/.local/bin}/tmux_active_pane_directory")

if [[ -z "$directory" ]]; then
  echo "No directory found"
  exit 1
fi

repository_url=$(cd "$directory" && gh url)

if [[ -z "$repository_url" ]]; then
  echo "No repository URL found" >&2
  exit 1
fi

echo "$repository_url"
