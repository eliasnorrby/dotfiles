#!/usr/bin/env bash

# This script is a wrapper for any command that needs to be run with elevated privileges.
# It will display a warning message in the status line of the tmux window where it is run.
# The message can be customized by setting the WARNING_WRAPPER_MESSAGE environment variable.

MESSAGE=${WARNING_WRAPPER_MESSAGE:-"HIGH PRIVILEGE OPERATION"}

tmux set -g 'status-format[0]' "#[align=centre]#[fill=red]#[bg=red,fg=black] $MESSAGE #[default]"

"$@"

tmux set -g 'status-format[0]' ''
