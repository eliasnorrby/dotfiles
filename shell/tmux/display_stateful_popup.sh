#!/usr/bin/env bash

# Display a tmux popup with a persistent session
# Usage: display_stateful_popup [options]
#   --title=<title>        Title for the popup (default: "Popup")
#   --color=<color>        Border color (default: "white")
#   --session=<suffix>     Session name suffix for the popup session
#   --attach-only          Only attach to existing session, don't create new one
#   -d <path>              Working directory (passed to display-popup)
#   -w <width>             Width (default: 70%)
#   -h <height>            Height (default: 70%)
#   [command...]           Command to run in the popup session

# Default values
title="Popup"
color="white"
session_suffix=""
attach_only=false
width="70%"
height="70%"
display_popup_args=()
create_session_args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title=*)
      title="${1#--title=}"
      shift
      ;;
    --color=*)
      color="${1#--color=}"
      shift
      ;;
    --session=*)
      session_suffix="${1#--session=}"
      create_session_args+=("--session=$session_suffix")
      shift
      ;;
    --attach-only)
      attach_only=true
      create_session_args+=("--attach-only")
      shift
      ;;
    -w)
      width="$2"
      shift 2
      ;;
    -h)
      height="$2"
      shift 2
      ;;
    -d)
      display_popup_args+=("-d" "$2")
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      # Remaining args are the command
      break
      ;;
  esac
done

# If --attach-only is set, check if session exists before displaying popup
if $attach_only; then
  current_session="$(tmux display -p '#S')"
  if [[ -n "$session_suffix" ]]; then
    session="_popup_${current_session}_${session_suffix}"
  else
    session="_popup_${current_session}"
  fi

  # Exit silently if session doesn't exist
  if ! tmux has-session -t "$session" 2>/dev/null; then
    exit 0
  fi
fi

# Build the command to execute inside the popup
# We need to properly quote all remaining arguments
cmd="create_popup_session"
for arg in "${create_session_args[@]}"; do
  cmd="$cmd $(printf '%q' "$arg")"
done
for arg in "$@"; do
  cmd="$cmd $(printf '%q' "$arg")"
done

# Build the display-popup command
tmux display-popup -E -b rounded \
  -T "#[fg=white bold] $title #[fg=default]" \
  -S "fg=$color" \
  -w "$width" \
  -h "$height" \
  "${display_popup_args[@]}" \
  "$cmd"
