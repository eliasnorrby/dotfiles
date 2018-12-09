#!/bin/bash

command=$1

if [ -z ${command} ]; then 
    echo "You must pass a command:"
    echo "monitor.sh 'docker stack ls'"
    exit;
fi

setdockerhost="export DOCKER_HOST=192.168.99.201; "
watch="$setdockerhost; watch -d -n 0.5 "
sessionname="monitor-widget"

tmux kill-session -t $sessionname

tmux set-option remain-on-exit off


tmux new-session -d -s $sessionname 
tmux send-keys " $watch $command" C-m

tmux split-window -p 90 -v 

tmux -2 attach-session -d -t $sessionname 

