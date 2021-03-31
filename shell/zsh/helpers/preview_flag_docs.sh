#!/usr/bin/env bash

# Usage: preview_flag_docs <command> <flag>

# Attempts to extract relevant documentation from the supplied command's
# manpage or --help output.

# Call man <command> if available, otherwise <command> --help
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

[ -z "$1" ] && echo "Must supply a command" && exit

if [ -z "$2" ] || [ -z "${2:1}" ] || [ "${2:0:1}" != "-" ]; then
  echo "Must supply a flag" && exit
fi

[ -n "$3" ] && echo "Too many arguments" && exit

_only_flag="${2%% *}"

_start="/^[[:blank:]]*${_only_flag}/"
_end="/^[[:blank:]]*-/"

# sed works, but fails on e.g. 'find -exec', which has multiple entries. It
# will only print one, but we want both.

# _sed="${_start},${_end} { ${_start}p; ${_end}!p; }"
# man-or-help "$1" | sed -n "${_sed}"

# awk on the other hand will print both, but also the entries for -execdir.
_awk_instructions="${_start}{flag=1;print \$0;next}${_end}{flag=0}flag"

man-or-help "$1" | awk "${_awk_instructions}"

