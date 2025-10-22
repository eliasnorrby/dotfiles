#!/usr/bin/env bash

# Generic smart toggle for stateful popups
# Usage: toggle_stateful_popup --session=<name> --title=<title> --color=<color> [--global] [--fallback-passthrough] [-w <width>] [-h <height>] [-d <path>] [command...]
#
# Behavior:
# - If popup session exists and is hidden: show it
# - If popup session exists and is in foreground: hide it
# - If popup session doesn't exist:
#   - With --fallback-passthrough: send the keybinding to underlying app
#   - Without --fallback-passthrough: create and show popup with command

session_name=""
title=""
color="white"
is_global=false
fallback_passthrough=false
width=""
height=""
directory=""
command_args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --fallback-passthrough)
      fallback_passthrough=true
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

# Validate required parameters
if [[ -z "$session_name" ]]; then
  echo "Error: --session=<name> is required" >&2
  exit 1
fi

if [[ -z "$title" ]]; then
  echo "Error: --title=<title> is required" >&2
  exit 1
fi

# Get current session info
current_session="$(tmux display -p '#S')"

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
    display_opts=(--title="$title" --color="$color" --session="$session_name" --attach-only)
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
  if $fallback_passthrough; then
    # Get the keybinding that triggered this script
    # We need to extract it from the command that called us
    # For now, we'll handle specific known cases
    case "$session_name" in
      prompt)
        tmux send-keys C-p
        ;;
      *)
        echo "Error: Unknown fallback keybinding for session '$session_name'" >&2
        exit 1
        ;;
    esac
  else
    # Create and show the popup with the command
    # Build display options
    display_opts=(--title="$title" --color="$color" --session="$session_name")
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
