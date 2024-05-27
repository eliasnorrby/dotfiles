#!/usr/bin/env bash

# Get the active session
active_session=$(tmux display-message -p '#S')

# Get the active window in the session
active_window=$(tmux display-message -p '#I')

# Get the active pane in the window
active_pane=$(tmux display-message -p '#P')

# Get the working directory of the active pane
working_directory=$(tmux display-message -p -t "$active_session:$active_window.$active_pane" '#{pane_current_path}')

echo "$working_directory"
