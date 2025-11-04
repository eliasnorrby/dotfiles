#!/usr/bin/env bash

# Get the current session name
current_session="$(tmux display -p '#S')"

# If we're in a popup session, extract the original session name
if [[ "$current_session" =~ ^_popup_(.+)_(.+)$ ]]; then
  # Extract base session name, stripping any suffix
  original_session="${BASH_REMATCH[1]}"
  current_session="$original_session"
elif [[ "$current_session" =~ ^_popup_(.+)$ ]]; then
  # Handle base popup without suffix (if any still exist)
  original_session="${BASH_REMATCH[1]}"
  current_session="$original_session"
fi

# If we extracted "GLOBAL" (from a global popup), find the real base session
if [[ "$current_session" == "GLOBAL" ]]; then
  # Get list of attached sessions, filtering out popups and runner
  current_session="$(tmux list-sessions -F '#{session_name}' | grep -v '^_popup_' | grep -v '^runner$' | head -n1)"
fi

# Build the expected popup session names (session-scoped)
terminal_popup="_popup_${current_session}_terminal"
prompt_popup="_popup_${current_session}_prompt"
scratch_popup="_popup_${current_session}_scratch"

# Global popups
tasks_popup="_popup_GLOBAL_tasks"
reminders_popup="_popup_GLOBAL_reminders"

# Check if popup sessions exist
base_active=""
prompt_active=""
scratch_active=""
tasks_active=""
reminders_active=""

if tmux has-session -t "$terminal_popup" 2>/dev/null; then
  base_active="#[fg=yellow]󰆍 #[fg=default]"
fi

if tmux has-session -t "$prompt_popup" 2>/dev/null; then
  prompt_active="#[fg=blue]󰷉 #[fg=default]"
fi

if tmux has-session -t "$scratch_popup" 2>/dev/null; then
  scratch_active="#[fg=cyan] #[fg=default]"
fi

if tmux has-session -t "$tasks_popup" 2>/dev/null; then
  tasks_active="#[fg=green] #[fg=default]"
fi

if tmux has-session -t "$reminders_popup" 2>/dev/null; then
  # Count active reminders
  reminder_count=$("$TMUX_HOME/scripts/count_reminders.sh")
  if [[ "$reminder_count" -gt 0 ]]; then
    reminders_active="#[fg=magenta]󰾨 $reminder_count#[fg=default]"
  else
    reminders_active=""
  fi
fi

# Output the indicators (they'll appear side by side if active)
echo " ${prompt_active} ${base_active} ${scratch_active} ${tasks_active} ${reminders_active}" | sed -E -e 's/[[:blank:]]+/ /g' -e 's/[[:blank:]]+$//g'
