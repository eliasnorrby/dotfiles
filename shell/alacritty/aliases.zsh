alias alac="vim $XDG_CONFIG_HOME/alacritty/alacritty.yml"

function theme() {
  local theme=${1:-${VIM_COLOR:-${DEFAULT_THEME}}}
  sed -i '' "s/^colors: \*.*/colors: \*$theme/" "$DOTFILES/shell/alacritty/alacritty.yml"
}

alias ayu="theme ayu"
alias gruvbox="theme gruvbox"
alias palenight="theme palenight"

function opacity() {
  local opacity=${1:-0.95}
  sed -i '' "s/^background_opacity: .*/background_opacity: $opacity/" "$DOTFILES/shell/alacritty/alacritty.yml"
}

