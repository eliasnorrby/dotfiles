function opacity() {
  local opacity=${1:-0.95}
  sed -i '' "s/^background_opacity: .*/background_opacity: $opacity/" "$DOTFILES/terminal/alacritty/alacritty.yml"
}
