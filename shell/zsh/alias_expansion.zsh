# alias expansion: https://blog.sebastian-daschner.com/entries/zsh-aliases

# blank aliases - don't add a space after expanding these
typeset -ga baliases
baliases=()

balias() {
  alias $@
  args="$@"
  args=${args%%\=*}
  baliases+=(${args##* })
}

# ignored aliases - don't expand these
typeset -ga ialiases
export ialiases=()

ialias() {
  alias $@
  args="$@"
  args=${args%%\=*}
  ialiases+=(${args##* })
}

# functionality
expand-alias-space() {
  local remove_space
  if (($baliases[(Ie)${LBUFFER##* }])) && [[ "$LBUFFER" == "${LBUFFER##* }" ]]; then
    remove_space="yes"
  fi
  if ! (($ialiases[(Ie)${LBUFFER##* }])); then
    zle _expand_alias
  fi
  zle self-insert
  if [[ -n "$remove_space" ]]; then
    zle backward-delete-char
  fi
}
zle -N expand-alias-space

bindkey " " expand-alias-space
# bindkey -M isearch " " magic-space


