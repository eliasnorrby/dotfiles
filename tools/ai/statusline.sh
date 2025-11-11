#!/usr/bin/env bash

# Claude status line
# https://docs.claude.com/en/docs/claude-code/statusline

# Parse arguments
DEBUG=false
if [[ "$1" == "--debug" ]]; then
  DEBUG=true
fi

# Read JSON input once
input=$(cat)

# Debug logging
if [[ "$DEBUG" == "true" ]]; then
  log_file="$HOME/.cache/claude/statusline.log"
  mkdir -p "$(dirname "$log_file")"
  {
    echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="
    echo "$input" | jq '.'
    echo ""
  } >>"$log_file"
fi

# ANSI color codes (standard 16 terminal colors)
COLOR_RESET='\033[0m'
COLOR_BOLD='\033[1m'
COLOR_DIM='\033[2m'

# Foreground colors
FG_BLACK='\033[30m'
FG_RED='\033[31m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_BLUE='\033[34m'
FG_MAGENTA='\033[35m'
FG_CYAN='\033[36m'
FG_WHITE='\033[37m'

# Bright foreground colors
FG_BRIGHT_BLACK='\033[90m'
FG_BRIGHT_RED='\033[91m'
FG_BRIGHT_GREEN='\033[92m'
FG_BRIGHT_YELLOW='\033[93m'
FG_BRIGHT_BLUE='\033[94m'
FG_BRIGHT_MAGENTA='\033[95m'
FG_BRIGHT_CYAN='\033[96m'
FG_BRIGHT_WHITE='\033[97m'

# ============================================================================
# Data extraction helpers
# ============================================================================

get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

get_git_branch() {
  local project_dir=$(get_project_dir)
  if [[ -f "$project_dir/.git/HEAD" ]]; then
    local ref=$(cat "$project_dir/.git/HEAD")
    if [[ $ref == ref:* ]]; then
      local branch="${ref#ref: refs/heads/}"
      if [[ ${#branch} -gt 35 ]]; then
        branch="${branch:0:35}..."
      fi
      echo "$branch"
    else
      echo "${ref:0:7}"  # detached HEAD
    fi
  fi
}

get_context_percentage() {
  local ccusage_output="$(echo "$input" | pnpm dlx ccusage statusline 2>/dev/null)"
  if [[ -n "$ccusage_output" ]]; then
    echo "$ccusage_output" | grep -oE '\([0-9]+%\)' | tr -d '()'
  fi
}

format_duration() {
  local ms=$1
  if [[ "$ms" == "null" ]] || [[ -z "$ms" ]]; then
    echo ""
    return
  fi
  local seconds=$((ms / 1000))
  if [[ $seconds -lt 60 ]]; then
    echo "${seconds}s"
  else
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    echo "${minutes}m ${remaining_seconds}s"
  fi
}

# ============================================================================
# Component functions (each returns a formatted string or empty if N/A)
# ============================================================================

component_model() {
  local model=$(get_model_name)
  if [[ -n "$model" ]] && [[ "$model" != "null" ]]; then
    echo "${FG_BRIGHT_BLUE}${COLOR_BOLD}  ${model}${COLOR_RESET}"
  fi
}

component_directory() {
  local current_dir=$(get_current_dir)
  if [[ -n "$current_dir" ]] && [[ "$current_dir" != "null" ]]; then
    local dir_name="${current_dir##*/}"
    echo "${FG_YELLOW}  ${dir_name}${COLOR_RESET}"
  fi
}

component_git_branch() {
  local branch=$(get_git_branch)
  if [[ -z "$branch" ]]; then
    return
  fi

  local output="${FG_BRIGHT_BLACK}${FG_WHITE}󰘬 ${branch}${COLOR_RESET}"

  # Add line changes to the same component
  local lines_added=$(get_lines_added)
  local lines_removed=$(get_lines_removed)

  if [[ "$lines_added" != "null" ]] && [[ "$lines_added" != "0" ]] && [[ -n "$lines_added" ]]; then
    output="${output} ${FG_GREEN}+${lines_added}${COLOR_RESET}"
  fi

  if [[ "$lines_removed" != "null" ]] && [[ "$lines_removed" != "0" ]] && [[ -n "$lines_removed" ]]; then
    output="${output} ${FG_RED}-${lines_removed}${COLOR_RESET}"
  fi

  echo "$output"
}

component_duration() {
  local duration=$(get_duration)
  local formatted=$(format_duration "$duration")

  if [[ -n "$formatted" ]]; then
    echo "${FG_BRIGHT_BLACK}  ${formatted}${COLOR_RESET}"
  fi
}

component_context() {
  local context_pct=$(get_context_percentage)
  if [[ -z "$context_pct" ]]; then
    return
  fi

  # Extract numeric percentage
  local pct_num=$(echo "$context_pct" | tr -d '%')

  # Determine color based on usage
  local bar_color
  if [[ $pct_num -lt 50 ]]; then
    bar_color="$FG_BRIGHT_WHITE"
  elif [[ $pct_num -lt 80 ]]; then
    bar_color="$FG_YELLOW"
  else
    bar_color="$FG_RED"
  fi

  # Create progress bar (20 characters wide)
  local bar_width=20
  local filled=$((pct_num * bar_width / 100))
  local empty=$((bar_width - filled))

  local bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done

  echo "${FG_BRIGHT_WHITE}  ${bar_color}${bar} ${context_pct}${COLOR_RESET}"
}

# ============================================================================
# Compose statusline
# ============================================================================

# Define component order here - reorder by changing the sequence
components=(
  component_model
  component_directory
  component_git_branch
  component_context
  component_duration
)

# Build the statusline by calling each component function
separator="${FG_BRIGHT_BLACK} │ ${COLOR_RESET}"
output=""
first=true

for component_fn in "${components[@]}"; do
  component_output=$($component_fn)

  # Only add non-empty components
  if [[ -n "$component_output" ]]; then
    if [[ "$first" == "true" ]]; then
      output="$component_output"
      first=false
    else
      output="${output}${separator}${component_output}"
    fi
  fi
done

# Output the final statusline
echo -e "$output"
