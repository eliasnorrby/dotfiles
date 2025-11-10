#!/usr/bin/env bash

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
REPO=""
USERNAME=""

# Counters for summary
TASKS_CREATED=0
TASKS_UPDATED=0
TASKS_COMPLETED=0
TASKS_DELETED=0
ERRORS=0

# Usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") --repo <org/repo> --username <github-username> [--dry-run]

Sync GitHub pull requests with Taskwarrior tasks.

Options:
    --repo <org/repo>           Repository to sync (required)
    --username <github-username> GitHub username (required)
    --dry-run, -n               Show what would be done without making changes
    --help, -h                  Show this help message

Examples:
    $(basename "$0") --repo myorg/myrepo --username johndoe
    $(basename "$0") --repo myorg/myrepo --username johndoe --dry-run
EOF
  exit 0
}

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

log_dry_run() {
  echo -e "${YELLOW}[DRY-RUN]${NC} $*"
}

# Execute or print command
execute_cmd() {
  local cmd="$*"
  if [ "$DRY_RUN" = true ]; then
    log_dry_run "$cmd"
    return 0
  else
    if eval "$cmd" 2>&1; then
      return 0
    else
      return 1
    fi
  fi
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --username)
      USERNAME="$2"
      shift 2
      ;;
    --dry-run | -n)
      DRY_RUN=true
      shift
      ;;
    --wait | -w)
      WAIT=true
      shift
      ;;
    --help | -h)
      usage
      ;;
    *)
      # If arg is a uuid, just ignore it. This allows invoking the script using taskwarrior-tuis shortcuts.
      if [[ "$1" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
        shift
        continue
      fi
      log_error "Unknown option: $1"
      usage
      ;;
    esac
  done

  # Validate required arguments
  if [ -z "$REPO" ]; then
    log_error "--repo is required"
    usage
  fi

  if [ -z "$USERNAME" ]; then
    log_error "--username is required"
    usage
  fi
}

# Check if required commands are available
check_dependencies() {
  local missing_deps=()

  if ! command -v gh &>/dev/null; then
    missing_deps+=("gh (GitHub CLI)")
  fi

  if ! command -v task &>/dev/null; then
    missing_deps+=("task (Taskwarrior)")
  fi

  if ! command -v jq &>/dev/null; then
    missing_deps+=("jq")
  fi

  if [ ${#missing_deps[@]} -gt 0 ]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    exit 1
  fi
}

# Check GitHub authentication
check_gh_auth() {
  log_info "Checking GitHub authentication..." >&2
  if ! gh auth status &>/dev/null; then
    log_error "GitHub CLI is not authenticated. Please run: gh auth login"
    exit 1
  fi
}

# Fetch open PRs from GitHub
fetch_open_prs() {
  log_info "Fetching open PRs from $REPO..." >&2
  local prs
  if ! prs=$(gh pr list --repo "$REPO" --state open \
    --json number,title,author,reviewRequests,reviews,reviewDecision 2>&1); then
    log_error "Failed to fetch PRs from $REPO: $prs"
    return 1
  fi
  echo "$prs"
}

# Get existing tasks for this repo
get_existing_tasks() {
  log_info "Fetching existing tasks for $REPO..." >&2
  task project:work +pr pr_repo:"$REPO" status:pending or status:waiting export 2>/dev/null || echo "[]"
}

# Check if PR has approval
has_approval() {
  local reviews="$1"
  echo "$reviews" | jq -r '.[] | select(.state == "APPROVED") | .state' | grep -q "APPROVED"
}

# Check if user is a reviewer
is_reviewer() {
  local review_requests="$1"
  local username="$2"
  echo "$review_requests" | jq -r '.[] | select(.login == "'"$username"'") | .login' | grep -q "$username"
}

# Check if user has already reviewed
has_user_reviewed() {
  local reviews="$1"
  local username="$2"
  echo "$reviews" | jq -r '.[] | select(.author.login == "'"$username"'") | .author.login' | grep -q "$username"
}

# Check if PR is authored by user
is_author() {
  local author="$1"
  local username="$2"
  [ "$(echo "$author" | jq -r '.login')" = "$username" ]
}

# Create task for PR
create_task() {
  local pr_number="$1"
  local title="$2"
  local task_type="$3"  # "merge" or "review"
  local needs_wait="$4" # "true" or "false"

  local description="[PR#${pr_number}] ${task_type^}: ${title}"
  local tags="project:work +pr +${task_type}"
  local wait_clause=""

  if [ "$task_type" = "merge" ] && [ "$needs_wait" = "true" ]; then
    tags="$tags +wait"
    wait_clause="wait:later"
  fi

  local cmd="task add \"${description}\" ${tags} pr_number:${pr_number} pr_repo:\"${REPO}\" ${wait_clause}"

  log_success "Creating task: $description"
  if execute_cmd "$cmd"; then
    ((TASKS_CREATED++))
    return 0
  else
    log_error "Failed to create task for PR#$pr_number"
    ((ERRORS++))
    return 1
  fi
}

# Update task wait status
update_task_wait() {
  local task_uuid="$1"
  local should_wait="$2" # "true" or "false"
  local current_wait="$3"

  if [ "$should_wait" = "true" ] && [ -z "$current_wait" ]; then
    log_success "Adding wait status to task $task_uuid"
    if execute_cmd "task $task_uuid modify wait:later +wait"; then
      ((TASKS_UPDATED++))
      return 0
    else
      log_error "Failed to add wait status to task $task_uuid"
      ((ERRORS++))
      return 1
    fi
  elif [ "$should_wait" = "false" ] && [ -n "$current_wait" ]; then
    log_success "Removing wait status from task $task_uuid"
    if execute_cmd "task $task_uuid modify wait: -wait"; then
      ((TASKS_UPDATED++))
      return 0
    else
      log_error "Failed to remove wait status from task $task_uuid"
      ((ERRORS++))
      return 1
    fi
  fi
}

# Complete task
complete_task() {
  local task_uuid="$1"
  local pr_number="$2"

  log_success "Completing task for PR#$pr_number"
  if execute_cmd "task $task_uuid done"; then
    ((TASKS_COMPLETED++))
    return 0
  else
    log_error "Failed to complete task for PR#$pr_number"
    ((ERRORS++))
    return 1
  fi
}

# Delete task
delete_task() {
  local task_uuid="$1"
  local pr_number="$2"

  log_success "Deleting task for PR#$pr_number"
  if execute_cmd "echo 'yes' | task $task_uuid delete"; then
    ((TASKS_DELETED++))
    return 0
  else
    log_error "Failed to delete task for PR#$pr_number"
    ((ERRORS++))
    return 1
  fi
}

# Process a single open PR
process_open_pr() {
  local pr_json="$1"
  local existing_tasks="$2"

  # Wrap in error handling to continue processing other PRs if one fails
  local pr_number
  if ! pr_number=$(echo "$pr_json" | jq -r '.number' 2>/dev/null); then
    log_error "Failed to parse PR number from JSON"
    ((ERRORS++))
    return 1
  fi

  local title
  local author
  local review_requests
  local reviews

  if ! title=$(echo "$pr_json" | jq -r '.title' 2>/dev/null) ||
    ! author=$(echo "$pr_json" | jq -r '.author' 2>/dev/null) ||
    ! review_requests=$(echo "$pr_json" | jq -c '.reviewRequests' 2>/dev/null) ||
    ! reviews=$(echo "$pr_json" | jq -c '.reviews' 2>/dev/null); then
    log_error "Failed to parse PR#$pr_number data"
    ((ERRORS++))
    return 1
  fi

  # Determine if this is my PR or a review PR
  local is_my_pr=false
  local is_review_pr=false

  if is_author "$author" "$USERNAME"; then
    is_my_pr=true
  fi

  # A PR is a "review PR" if you're currently requested OR you've already reviewed
  if is_reviewer "$review_requests" "$USERNAME" || has_user_reviewed "$reviews" "$USERNAME"; then
    is_review_pr=true
  fi

  # Find existing task
  local existing_task
  existing_task=$(echo "$existing_tasks" | jq -r '.[] | select(.pr_number == '"$pr_number"')')

  if [ "$is_my_pr" = true ]; then
    # Handle PR to merge
    local needs_wait="true"
    if has_approval "$reviews"; then
      needs_wait="false"
    fi

    if [ -z "$existing_task" ]; then
      create_task "$pr_number" "$title" "merge" "$needs_wait" || true
    else
      # Check if wait status needs updating
      local task_uuid
      local current_wait
      task_uuid=$(echo "$existing_task" | jq -r '.uuid')
      current_wait=$(echo "$existing_task" | jq -r '.wait // empty')
      update_task_wait "$task_uuid" "$needs_wait" "$current_wait" || true
    fi
  elif [ "$is_review_pr" = true ]; then
    # Handle PR to review
    local user_reviewed=false
    if has_user_reviewed "$reviews" "$USERNAME"; then
      user_reviewed=true
    fi

    if [ "$user_reviewed" = true ] && [ -n "$existing_task" ]; then
      # User has reviewed - complete the task
      local task_uuid
      task_uuid=$(echo "$existing_task" | jq -r '.uuid')
      complete_task "$task_uuid" "$pr_number" || true
    elif [ "$user_reviewed" = false ] && [ -z "$existing_task" ]; then
      # User hasn't reviewed yet - create task
      create_task "$pr_number" "$title" "review" "false" || true
    fi
    # If reviewed but no task exists, or not reviewed but task exists, do nothing
  fi
}

# Handle orphaned tasks (PRs that are no longer open)
handle_orphaned_tasks() {
  local existing_tasks="$1"
  local open_pr_numbers="$2"

  # Get all task PR numbers (filter out null values)
  local task_pr_numbers
  task_pr_numbers=$(echo "$existing_tasks" | jq -r '.[] | select(.pr_number != null) | .pr_number' | sort -n)

  for pr_number in $task_pr_numbers; do
    # Skip if pr_number is empty or invalid
    if [ -z "$pr_number" ] || [ "$pr_number" = "null" ]; then
      continue
    fi

    if ! echo "$open_pr_numbers" | grep -q "^${pr_number}$"; then
      # This task has no corresponding open PR
      log_info "PR#$pr_number is no longer open, checking status..."

      # Fetch PR details with timeout
      local pr_data
      if ! pr_data=$(timeout 5 gh pr view "$pr_number" --repo "$REPO" --json state,mergedAt 2>&1); then
        log_warning "Could not fetch data for PR#$pr_number"
        ((ERRORS++))
        continue
      fi

      if [ -z "$pr_data" ] || [ "$pr_data" = "{}" ] || [ "$pr_data" = "null" ]; then
        log_warning "No data returned for PR#$pr_number"
        ((ERRORS++))
        continue
      fi

      local state
      if ! state=$(echo "$pr_data" | jq -r '.state' 2>/dev/null); then
        log_warning "Failed to parse PR#$pr_number data"
        ((ERRORS++))
        continue
      fi

      local task_uuid
      task_uuid=$(echo "$existing_tasks" | jq -r '.[] | select(.pr_number == '"$pr_number"') | .uuid')

      if [ "$state" = "MERGED" ]; then
        complete_task "$task_uuid" "$pr_number" || true
      elif [ "$state" = "CLOSED" ]; then
        delete_task "$task_uuid" "$pr_number" || true
      fi
    fi
  done
}

# Main function
main() {
  parse_args "$@"
  check_dependencies
  check_gh_auth

  if [ "$DRY_RUN" = true ]; then
    log_warning "Running in DRY-RUN mode. No changes will be made."
  fi

  log_info "Syncing PRs for repository: $REPO"
  log_info "GitHub username: $USERNAME"
  echo ""

  # Fetch data
  local open_prs
  if ! open_prs=$(fetch_open_prs); then
    log_error "Failed to fetch PRs. Exiting."
    exit 1
  fi

  local existing_tasks
  existing_tasks=$(get_existing_tasks)

  local open_pr_count
  local existing_task_count
  open_pr_count=$(echo "$open_prs" | jq 'length')
  existing_task_count=$(echo "$existing_tasks" | jq 'length')

  log_info "Found $open_pr_count open PRs"
  log_info "Found $existing_task_count existing tasks"
  echo ""

  # Process each open PR
  if [ "$open_pr_count" -gt 0 ]; then
    for i in $(seq 0 $((open_pr_count - 1))); do
      local pr_json
      pr_json=$(echo "$open_prs" | jq ".[$i]")
      process_open_pr "$pr_json" "$existing_tasks" || true
    done
  fi

  echo ""

  # Handle orphaned tasks
  local open_pr_numbers
  open_pr_numbers=$(echo "$open_prs" | jq -r '.[].number')
  handle_orphaned_tasks "$existing_tasks" "$open_pr_numbers"

  echo ""

  # Print summary
  log_success "Sync complete!"
  echo ""
  log_info "Summary:"
  log_info "  Tasks created:   $TASKS_CREATED"
  log_info "  Tasks updated:   $TASKS_UPDATED"
  log_info "  Tasks completed: $TASKS_COMPLETED"
  log_info "  Tasks deleted:   $TASKS_DELETED"

  if [ "$ERRORS" -gt 0 ]; then
    log_warning "  Errors:          $ERRORS"
    exit 1
  else
    log_info "  Errors:          $ERRORS"
  fi

  if [ "$WAIT" = true ]; then
    log_info "Waiting for user input before exiting..."
    read -r -p "Press Enter to continue..."
  fi
}

main "$@"

date >>~/.cache/gh_pr_task_sync.log
