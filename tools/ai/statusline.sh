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
  } >> "$log_file"
fi

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
echo "[$MODEL] 📁 ${DIR##*/}"
