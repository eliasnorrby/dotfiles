if [[ "$(_os)" == "macos" ]]; then
  sed_bak_str=\'\'
fi
function theme() {
  local theme=${1:-${VIM_COLOR:-${DEFAULT_THEME}}}
  sed -i $sed_bak_str "s/^colors: \*.*/colors: \*$theme/" "$DOTFILES/terminal/alacritty/alacritty.yml"
}

function opacity() {
  local opacity=${1:-0.95}
  sed -i '' "s/^background_opacity: .*/background_opacity: $opacity/" "$DOTFILES/terminal/alacritty/alacritty.yml"
}

