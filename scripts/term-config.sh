#!/bin/bash

sessionname="term-config"

tmux kill-session -t $sessionname

tmux new-session -d -s $sessionname

tmux set-option remain-on-exit off

tmux send-keys " vim ~/.dotfiles/zshrc.zsh" C-m

tmux split-window -p 50 -h
tmux send-keys " vim ~/.dotfiles/aliases.zsh" C-m

tmux -2 attach-session -d -t $sessionname 

