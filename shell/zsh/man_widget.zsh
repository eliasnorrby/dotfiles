PREVIEW_SCRIPT=preview_flag_docs

man-widget() {
  local mode="complete"
  local command=$(get-command-from-buffer)

  if [ -z "$command" ]; then
    command=$(select-command)
    mode="lookup"
  fi

  [ -z "$command" ] && return

  if ! command -v "$command" >/dev/null 2>&1; then
    return
  fi

  local flag=$(select-flag "$command")

  [ -z "$flag" ] && return

  case $mode in
    lookup)
      echo
      # "${PREVIEW_SCRIPT} "$command" "$flag"
      go-to-docs "$command" "$flag"
      ;;
    complete)
      add-flag "$flag"
      ;;
  esac

  zle reset-prompt
}

zle -N man-widget
bindkey '^F^M' man-widget

get-command-from-buffer() {
  [ -z "$BUFFER" ] && return
  local without_pipes="${LBUFFER##*|}"
  local without_subshell="${without_pipes##*\(}"
  sed 's/^[[:blank:]]*//'<<<"${without_subshell}" | cut -d ' ' -f1
}

select-command() {
  compgen -c | fzf
}

select-flag() {
  local preview
  local window
  if command -v "${PREVIEW_SCRIPT}" >/dev/null 2>&1; then
    preview="${PREVIEW_SCRIPT} ${1} {}"
    window='down:70%'
  else
    preview="echo 'Could not find preview script'"
    window='down:10%'
  fi

  man-or-help $1 \
    | grep '^[[:blank:]]*-[^ ]' \
    | sed 's/^[[:blank:]]*//' \
    | fzf \
    --preview "${preview}" \
    --preview-window "${window}" \
    | strip-to-only-flag
}

man-or-help() {
  [ -z "$1" ] && return
  if has-man "$1"; then
    man "$1" | col -b
  elif command -v "$1" >/dev/null 2>&1; then
    "$1" --help 2>&1
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
  local less_opts="${LESS/-i//}"
  less_opts="${less_opts/-I//}"
  man-or-help $1 | LESS="$less_opts" less "+/^[[:blank:]]*${2}"
}

