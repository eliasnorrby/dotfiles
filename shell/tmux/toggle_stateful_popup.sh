#!/usr/bin/env bash

# Generic smart toggle for stateful popups
# Usage: toggle_stateful_popup --session=<name> --title=<title> --color=<color> [--global] [--fallback <command>] [-w <width>] [-h <height>] [-d <path>] [command...]
#
# Behavior:
# - If popup session exists and is hidden: show it
# - If popup session exists and is in foreground: hide it
# - If popup session doesn't exist:
#   - With --fallback: execute the specified fallback command
#   - Without --fallback: create and show popup with command

session_name=""
title=""
color="white"
is_global=false
is_dismiss=false
fallback_command=""
width=""
height=""
directory=""
display_popup_args=()
command_args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dismiss)
      is_dismiss=true
      shift
      ;;
    --session=*)
      session_name="${1#--session=}"
      shift
      ;;
    --title=*)
      title="${1#--title=}"
      shift
      ;;
    --color=*)
      color="${1#--color=}"
      shift
      ;;
    --global)
      is_global=true
      shift
      ;;
    --fallback)
      fallback_command="$2"
      shift 2
      ;;
    -w)
      width="$2"
      shift 2
      ;;
    -h)
      height="$2"
      shift 2
      ;;
    -x)
      display_popup_args+=("-x" "$2")
      shift 2
      ;;
    -y)
      display_popup_args+=("-y" "$2")
      shift 2
      ;;
    -d)
      directory="$2"
      shift 2
      ;;
    --)
      shift
      command_args=("$@")
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      # Remaining args are the command
      command_args=("$@")
      break
      ;;
  esac
done

# Get current session info
current_session="$(tmux display -p '#S')"

# If --dismiss is set, we don't need a session
if $is_dismiss; then
  tmux detach-client
  exit 0
fi

# Validate required parameters
if [[ -z "$session_name" ]]; then
  echo "Error: --session=<name> is required" >&2
  exit 1
fi

if [[ -z "$title" ]]; then
  echo "Error: --title=<title> is required" >&2
  exit 1
fi

# Determine the base session name (handle if we're already in a popup)
if [[ "$current_session" =~ ^_popup_(.+)_(.+)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
elif [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  base_session="${BASH_REMATCH[1]}"
else
  base_session="$current_session"
fi

# Build the popup session name
if $is_global; then
  popup_session="_popup_GLOBAL_${session_name}"
else
  popup_session="_popup_${base_session}_${session_name}"
fi

# Check if popup session exists
if tmux has-session -t "$popup_session" 2>/dev/null; then
  # Session exists - check if we're currently in it (foreground)
  if [[ "$current_session" == "$popup_session" ]]; then
    # We're in the popup - detach to hide it
    tmux detach-client
  else
    # We're not in the popup - show it
    # Build display options
    display_opts=(--title="$title" --color="$color" --session="$session_name" --attach-only "${display_popup_args[@]}")
    if $is_global; then
      display_opts+=(--global)
    fi
    if [[ -n "$width" ]]; then
      display_opts+=(-w "$width")
    fi
    if [[ -n "$height" ]]; then
      display_opts+=(-h "$height")
    fi
    if [[ -n "$directory" ]]; then
      display_opts+=(-d "$directory")
    fi
    display_stateful_popup "${display_opts[@]}"
  fi
else
  # Session doesn't exist
  if [[ -n "$fallback_command" ]]; then
    # Execute the fallback command
    eval "$fallback_command"
  else
    # Create and show the popup with the command
    # Build display options
    display_opts=(--title="$title" --color="$color" --session="$session_name" "${display_popup_args[@]}")
    if $is_global; then
      display_opts+=(--global)
    fi
    if [[ -n "$width" ]]; then
      display_opts+=(-w "$width")
    fi
    if [[ -n "$height" ]]; then
      display_opts+=(-h "$height")
    fi
    if [[ -n "$directory" ]]; then
      display_opts+=(-d "$directory")
    fi
    display_stateful_popup "${display_opts[@]}" "${command_args[@]}"
  fi
fi
