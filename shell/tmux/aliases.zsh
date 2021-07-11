#!/usr/bin/env zsh

ialias tmux='tmux -f "$TMUX_HOME/tmux.conf"'

tmux_attach_default() {
  tmux attach -t default 2>/dev/null || tmux new -s default
}
alias ta="tmux_attach_default"

tn() {
  if [[ $# -eq 0 ]] ; then
    echo 'Error: must specify a session name'
    return 1
  fi
  tmux new-session -s "$1"
}

# ftm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `ftm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# ftmk [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `ftmk` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftmk` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}
