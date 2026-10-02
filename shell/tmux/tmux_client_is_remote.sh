#!/usr/bin/env bash
# Exit 0 when the tmux client that issued the current command is attached
# over ssh or mosh, 1 when it is a local terminal or there is no client.
#
# tmux's own IS_REMOTE_SESSION is a snapshot taken when the server loaded its
# config, so it says where the server was started, not where you are looking
# from. The live fact is the attached client: its process sits under
# mosh-server or sshd when remote and under a terminal emulator when local.
# `ps` keeps the walk portable across Linux and macOS.

pid=$(tmux display-message -p '#{client_pid}' 2>/dev/null)
[ -n "$pid" ] || exit 1

while [ "$pid" -gt 1 ]; do
  case $(ps -o comm= -p "$pid") in
    *mosh-server* | *sshd*) exit 0 ;;
  esac
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  [ -n "$pid" ] || break
done

exit 1
