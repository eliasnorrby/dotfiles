#!/usr/bin/env bash

# Claude Code in a plain fullscreen neovim terminal buffer: vim motions over
# the transcript via normal mode, nothing else. Arguments go to claude, so
# `claude_vim --resume <id>` and `claude_vim --continue` work; the V alias
# points here, and wk launches Claude through it when start.claude says so.
#
# The command reaches :terminal through an environment variable rather than
# on the Ex command line: :terminal truncates a long command (a first prompt
# of a couple of thousand characters ends in "E114: Missing quote" and the
# dashboard instead of Claude). Each argument is shell-quoted so the shell
# that :terminal runs can eval the string back into the same argv.

set -euo pipefail

command="claude"
for arg in "$@"; do
  command+=" $(printf '%q' "$arg")"
done

CLAUDE_VIM_COMMAND="$command" exec nvim '+terminal eval "$CLAUDE_VIM_COMMAND"' +startinsert
