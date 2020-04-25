alias alac="vim $XDG_CONFIG_HOME/alacritty/alacritty.yml"

function theme() {
  local theme=${1:-${VIM_COLOR:-${DEFAULT_THEME}}}
  sed -i'.bak' "s/^colors: \*.*/colors: \*$theme/" "$DOTFILES/shell/alacritty/alacritty.yml"
}

alias ayu="theme ayu"
alias gruvbox="theme gruvbox"
alias palenight="theme palenight"
