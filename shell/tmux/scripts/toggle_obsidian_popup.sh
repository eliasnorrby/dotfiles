#!/usr/bin/env bash

# Smart toggle for obsidian popup
# Wrapper around toggle_stateful_popup with obsidian-specific settings

exec toggle_stateful_popup \
  --session=obsidian \
  --title=Obsidian \
  --color=purple \
  -x R \
  -w '55%' \
  -h '90%' \
  -d "$HOME/vaults/bemlo" \
  nvim '+set nonu nornu'
