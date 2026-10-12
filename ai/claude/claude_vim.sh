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

# nvim exists only to host Claude, so quit it when Claude exits cleanly
# (/exit, ctrl-d) instead of leaving a "[Process exited 0]" buffer that
# wants a key press and then an empty buffer to :q. `confirm` asks before
# dropping changes to other buffers. A failure leaves the buffer up, so an
# error (a bad --resume id, say) stays readable.
on_exit='lua vim.api.nvim_create_autocmd("TermClose", { buffer = 0, once = true, callback = function() if vim.v.event.status == 0 then vim.schedule(function() vim.cmd("confirm qall") end) end end })'

# shellcheck disable=SC2016 # expanded by the shell :terminal runs, not here
CLAUDE_VIM_COMMAND="$command" exec nvim '+terminal eval "$CLAUDE_VIM_COMMAND"' "+$on_exit" +startinsert
