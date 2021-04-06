#!/usr/bin/env bash

# Usage: preview_flag_docs <flag> <command>

# Attempts to extract relevant documentation from the supplied command's
# manpage or --help output.

# Call man <command> if available, otherwise <command> --help
man-or-help() {
  local command=("$@")
  [ -z "${command[*]}" ] && return
  if ! has-space "${command[*]}" && has-man "${command[0]}"; then
    man "${command[0]}" | col -b
  else
    "${command[@]}" --help 2>&1
  fi
}

has-space() {
  test "${1#* }" != "${1}"
}

has-man() {
  [ "${1:0:1}" != '.' ] && man "$1" >/dev/null 2>&1
}

flag=$1
shift
command=("$@")

[ -z "${command[*]}" ] && echo "Must supply a command" && exit

if [ -z "$flag" ] || [ -z "${flag:1}" ] || [ "${flag:0:1}" != "-" ]; then
  echo "Must supply a flag" && exit
fi

_only_flag="${flag%% *}"

_start="/^[[:blank:]]*${_only_flag}/"
_end="/^[[:blank:]]*-/"

_awk_instructions="${_start}{flag=1;print \$0;next}${_end}{flag=0}flag"

echo "command: ${command[*]}, flag: $_only_flag"
echo
man-or-help "${command[@]}" | awk "${_awk_instructions}"
