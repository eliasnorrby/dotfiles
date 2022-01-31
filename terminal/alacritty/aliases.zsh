alias alac="vim $XDG_CONFIG_HOME/alacritty/alacritty.yml"

if [[ "$(_os)" == "macos" ]]; then
  sed_bak_str=\'\'
fi
function theme() {
  local theme=${1:-${VIM_COLOR:-${DEFAULT_THEME}}}
  sed -i $sed_bak_str "s/^colors: \*.*/colors: \*$theme/" "$DOTFILES/shell/alacritty/alacritty.yml"
}

alias ayu="theme ayu"
alias gruvbox="theme gruvbox"
alias palenight="theme palenight"

function opacity() {
  local opacity=${1:-0.95}
  sed -i '' "s/^background_opacity: .*/background_opacity: $opacity/" "$DOTFILES/shell/alacritty/alacritty.yml"
}

