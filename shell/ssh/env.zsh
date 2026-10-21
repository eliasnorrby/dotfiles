# The agent is systemd's ssh-agent.socket, at a fixed path, so every zsh finds
# it however it was started: interactive or not, in a tmux pane whose session
# a mosh client created (mosh carries no agent, so tmux unsets SSH_AUTH_SOCK
# there). A live socket already in the environment, such as macOS's launchd
# agent or one forwarded with ssh -A, is kept.
if [[ ! -S $SSH_AUTH_SOCK && -S ${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket ]]; then
  export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket
fi
