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

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Git branch detection
get_git_branch() {
  local project_dir=$(get_project_dir)
  if [[ -f "$project_dir/.git/HEAD" ]]; then
    local ref=$(cat "$project_dir/.git/HEAD")
    if [[ $ref == ref:* ]]; then
      echo "${ref#ref: refs/heads/}"
    else
      echo "${ref:0:7}"  # detached HEAD
    fi
  fi
}

# Format duration as human readable
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

# Get context usage from ccusage
ccusage_output="$(echo "$input" | pnpm dlx ccusage statusline 2>/dev/null)"

# Parse context percentage from ccusage output (format: "🧠 50,699 (25%)")
context_pct=""
if [[ -n "$ccusage_output" ]]; then
  context_pct=$(echo "$ccusage_output" | grep -oE '\([0-9]+%\)' | tr -d '()')
fi

# Build statusline components
MODEL=$(get_model_name)
CURRENT_DIR=$(get_current_dir)
PROJECT_DIR=$(get_project_dir)
GIT_BRANCH=$(get_git_branch)
DURATION=$(get_duration)
LINES_ADDED=$(get_lines_added)
LINES_REMOVED=$(get_lines_removed)

# Component array
components=()

# Model name (bright blue with chip icon)
components+=("${FG_BRIGHT_BLUE}${COLOR_BOLD}  ${MODEL}${COLOR_RESET}")

# Current directory (yellow with folder icon)
if [[ "$CURRENT_DIR" != "null" ]] && [[ -n "$CURRENT_DIR" ]]; then
  DIR_NAME="${CURRENT_DIR##*/}"
  components+=("${FG_YELLOW}  ${DIR_NAME}${COLOR_RESET}")
fi

# Git branch with line changes (white branch name with colored stats)
if [[ -n "$GIT_BRANCH" ]]; then
  git_component="${FG_BRIGHT_BLACK}${FG_WHITE}󰘬 ${GIT_BRANCH}${COLOR_RESET}"

  # Add line changes to the same component
  if [[ "$LINES_ADDED" != "null" ]] && [[ "$LINES_ADDED" != "0" ]] && [[ -n "$LINES_ADDED" ]]; then
    git_component="${git_component} ${FG_GREEN}+${LINES_ADDED}${COLOR_RESET}"
  fi
  if [[ "$LINES_REMOVED" != "null" ]] && [[ "$LINES_REMOVED" != "0" ]] && [[ -n "$LINES_REMOVED" ]]; then
    git_component="${git_component} ${FG_RED}-${LINES_REMOVED}${COLOR_RESET}"
  fi

  components+=("${git_component}")
fi

# Duration (dim white with clock icon)
FORMATTED_DURATION=$(format_duration "$DURATION")
if [[ -n "$FORMATTED_DURATION" ]]; then
  components+=("${FG_BRIGHT_BLACK}  ${FORMATTED_DURATION}${COLOR_RESET}")
fi

# Context usage with progress bar
if [[ -n "$context_pct" ]]; then
  # Extract numeric percentage
  pct_num=$(echo "$context_pct" | tr -d '%')

  # Determine color based on usage
  if [[ $pct_num -lt 50 ]]; then
    bar_color="$FG_BRIGHT_BLACK"
  elif [[ $pct_num -lt 80 ]]; then
    bar_color="$FG_YELLOW"
  else
    bar_color="$FG_RED"
  fi

  # Create progress bar (20 characters wide)
  bar_width=20
  filled=$((pct_num * bar_width / 100))
  empty=$((bar_width - filled))

  bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done

  components+=("${FG_BRIGHT_WHITE}  ${bar_color}${bar} ${context_pct}${COLOR_RESET}")
fi

# Join components with dim separator
separator="${FG_BRIGHT_BLACK} │ ${COLOR_RESET}"
output=""
for i in "${!components[@]}"; do
  if [[ $i -eq 0 ]]; then
    output="${components[$i]}"
  else
    output="${output}${separator}${components[$i]}"
  fi
done

# Output single line
echo -e "$output"
