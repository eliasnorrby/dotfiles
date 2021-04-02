brew() {
  local coreutils=/usr/local/opt/coreutils/libexec/gnubin
  path=("${path[@]/$coreutils}") /usr/local/bin/brew $@
}
