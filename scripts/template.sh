#!/usr/bin/env bash

ERROR="Bad usage, see $0 -h"

read -r -d "" USAGE <<EOF
Short description

Usage: ${0##*/} [-fh]
  -f ARG      Do something
  -h          Show usage

Example:
  ${0##*/} -f my-arg

EOF

set -eo pipefail

while getopts f:h opt; do
  case $opt in
    f) VAR=$OPTARG                         ;;
    h) echo "$USAGE" && exit 0             ;;
    *) echo "$ERROR" && exit 1             ;;
  esac
done
