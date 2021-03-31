PREVIEW_SCRIPT=preview_flag_docs

man-widget() {
  local mode="complete"
  local command=($(get-command-from-buffer | xargs))

  if [ -z "$command" ]; then
    command=($(select-command | xargs))
    mode="lookup"
  fi

  [ -z "$command" ] && return

  if ! is-callable-or-has-callable-base "$command"; then
    return
  fi

  local flag=$(select-flag ${command[@]})

  [ -z "$flag" ] && return

  case $mode in
    lookup)
      echo
      # "${PREVIEW_SCRIPT}" "$flag" ${command[@]}
      go-to-docs "$flag" ${command[@]}
      ;;
    complete)
      add-flag "$flag"
      ;;
  esac

  # zle reset-prompt
}

zle -N man-widget
bindkey '^F^M' man-widget

get-command-from-buffer() {
  [ -z "$BUFFER" ] && return
  local without_pipes="${LBUFFER##*|}"
  local without_subshell="${without_pipes##*\(}"
  local without_flags="${without_subshell%% -*}"
  local trimmed=$(xargs <<<"${without_flags}")

  if [ "${trimmed%% *}" = "find" ]; then
    echo -n "find"
  else
    echo -n "$trimmed"
  fi
}

select-command() {
  compgen -c | fzf --print-query --bind 'alt-enter:print-query' | tail -1
}

select-flag() {
  local command=("$@")
  local preview
  local window
  if command -v "${PREVIEW_SCRIPT}" >/dev/null 2>&1; then
    preview="${PREVIEW_SCRIPT} {} ${command[*]}"
    window='down:70%'
  else
    preview="echo 'Could not find preview script'"
    window='down:10%'
  fi

  man-or-help ${command[@]} \
    | grep '^[[:blank:]]*-[^ ]' \
    | sed -e 's/^[[:blank:]]*//' -e '/^---/d' \
    | fzf \
    --preview "${preview}" \
    --preview-window "${window}" \
    | strip-to-only-flag
}

has-space() {
  test "${1#* }" != "${1}"
}

is-callable() {
  command -v "$1" >/dev/null
}

is-callable-or-has-callable-base() {
  if has-space "$1"; then
    is-callable "${1%% *}"
  else
    is-callable "$1"
  fi
}

man-or-help() {
  local command=("$@")
  [ -z "${command[*]}" ] && return
  if ! has-space "${command[*]}" && has-man "${command[1]}"; then
    man "${command[1]}" | col -b
  else
    "${command[@]}" --help 2>&1
  fi
}

has-man() {
  man "$1" >/dev/null 2>&1
}

strip-to-only-flag() {
  cut -d ',' -f1 | cut -d ' ' -f1
}

add-flag() {
  if [ "${LBUFFER: -1}" = " " ]; then
    LBUFFER="${LBUFFER}$1"
    return
  fi

  local last_word=${LBUFFER##* }

  # if is_string_of_flags and is_short_flag
  if [ "${last_word:0:1}" = "-" ] && [ "${last_word:0:2}" != "--" ] && [ -z "${1:2}" ]; then
    LBUFFER="${LBUFFER}${1:1:1}"
  else
    LBUFFER="${LBUFFER} ${1}"
  fi
}

go-to-docs() {
  local flag=$1
  shift
  local command=("$@")
  local less_opts="${LESS/-i/}"
  less_opts="${less_opts/-I/}"
  less_opts="${less_opts/-F/}"
  man-or-help ${command[@]} | LESS="$less_opts" less "+/^[[:blank:]]*${flag}"
}

