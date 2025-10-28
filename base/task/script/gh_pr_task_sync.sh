#!/usr/bin/env bash

set -euo pipefail

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
    else
        eval "$cmd"
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
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            *)
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

    if ! command -v gh &> /dev/null; then
        missing_deps+=("gh (GitHub CLI)")
    fi

    if ! command -v task &> /dev/null; then
        missing_deps+=("task (Taskwarrior)")
    fi

    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Fetch open PRs from GitHub
fetch_open_prs() {
    log_info "Fetching open PRs from $REPO..." >&2
    gh pr list --repo "$REPO" --state open \
        --json number,title,author,reviewRequests,reviews,reviewDecision
}

# Get existing tasks for this repo
get_existing_tasks() {
    log_info "Fetching existing tasks for $REPO..." >&2
    task project:work +pr pr_repo:"$REPO" export 2>/dev/null || echo "[]"
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
    echo "$review_requests" | jq -r '.[] | select(.login == "'$username'") | .login' | grep -q "$username"
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
    local needs_wait="$4"  # "true" or "false"

    local description="[PR#${pr_number}] ${task_type^}: ${title}"
    local tags="project:work +pr +${task_type}"
    local wait_clause=""

    if [ "$task_type" = "merge" ] && [ "$needs_wait" = "true" ]; then
        tags="$tags +wait"
        wait_clause="wait:later"
    fi

    local cmd="task add \"${description}\" ${tags} pr_number:${pr_number} pr_repo:\"${REPO}\" ${wait_clause}"

    log_success "Creating task: $description"
    execute_cmd "$cmd"
}

# Update task wait status
update_task_wait() {
    local task_uuid="$1"
    local should_wait="$2"  # "true" or "false"
    local current_wait="$3"

    if [ "$should_wait" = "true" ] && [ -z "$current_wait" ]; then
        log_success "Adding wait status to task $task_uuid"
        execute_cmd "task $task_uuid modify wait:later +wait"
    elif [ "$should_wait" = "false" ] && [ -n "$current_wait" ]; then
        log_success "Removing wait status from task $task_uuid"
        execute_cmd "task $task_uuid modify wait: -wait"
    fi
}

# Complete task
complete_task() {
    local task_uuid="$1"
    local pr_number="$2"

    log_success "Completing task for PR#$pr_number"
    execute_cmd "task $task_uuid done"
}

# Delete task
delete_task() {
    local task_uuid="$1"
    local pr_number="$2"

    log_success "Deleting task for PR#$pr_number"
    execute_cmd "echo 'yes' | task $task_uuid delete"
}

# Process a single open PR
process_open_pr() {
    local pr_json="$1"
    local existing_tasks="$2"

    local pr_number=$(echo "$pr_json" | jq -r '.number')
    local title=$(echo "$pr_json" | jq -r '.title')
    local author=$(echo "$pr_json" | jq -r '.author')
    local review_requests=$(echo "$pr_json" | jq -c '.reviewRequests')
    local reviews=$(echo "$pr_json" | jq -c '.reviews')

    # Determine if this is my PR or a review PR
    local is_my_pr=false
    local is_review_pr=false

    if is_author "$author" "$USERNAME"; then
        is_my_pr=true
    fi

    if is_reviewer "$review_requests" "$USERNAME"; then
        is_review_pr=true
    fi

    # Find existing task
    local existing_task=$(echo "$existing_tasks" | jq -r '.[] | select(.pr_number == '$pr_number')')

    if [ "$is_my_pr" = true ]; then
        # Handle PR to merge
        local needs_wait="true"
        if has_approval "$reviews"; then
            needs_wait="false"
        fi

        if [ -z "$existing_task" ]; then
            create_task "$pr_number" "$title" "merge" "$needs_wait"
        else
            # Check if wait status needs updating
            local task_uuid=$(echo "$existing_task" | jq -r '.uuid')
            local current_wait=$(echo "$existing_task" | jq -r '.wait // empty')
            update_task_wait "$task_uuid" "$needs_wait" "$current_wait"
        fi
    elif [ "$is_review_pr" = true ]; then
        # Handle PR to review
        if [ -z "$existing_task" ]; then
            create_task "$pr_number" "$title" "review" "false"
        fi
    fi
}

# Handle orphaned tasks (PRs that are no longer open)
handle_orphaned_tasks() {
    local existing_tasks="$1"
    local open_pr_numbers="$2"

    # Get all task PR numbers
    local task_pr_numbers=$(echo "$existing_tasks" | jq -r '.[].pr_number' | sort -n)

    for pr_number in $task_pr_numbers; do
        if ! echo "$open_pr_numbers" | grep -q "^${pr_number}$"; then
            # This task has no corresponding open PR
            log_info "PR#$pr_number is no longer open, checking status..."

            # Fetch PR details
            local pr_data=$(gh pr view "$pr_number" --repo "$REPO" --json state,mergedAt 2>/dev/null || echo "{}")

            if [ -z "$pr_data" ] || [ "$pr_data" = "{}" ]; then
                log_warning "Could not fetch data for PR#$pr_number"
                continue
            fi

            local state=$(echo "$pr_data" | jq -r '.state')
            local merged_at=$(echo "$pr_data" | jq -r '.mergedAt')

            local task_uuid=$(echo "$existing_tasks" | jq -r '.[] | select(.pr_number == '$pr_number') | .uuid')

            if [ "$state" = "MERGED" ]; then
                complete_task "$task_uuid" "$pr_number"
            elif [ "$state" = "CLOSED" ]; then
                delete_task "$task_uuid" "$pr_number"
            fi
        fi
    done
}

# Main function
main() {
    parse_args "$@"
    check_dependencies

    if [ "$DRY_RUN" = true ]; then
        log_warning "Running in DRY-RUN mode. No changes will be made."
    fi

    log_info "Syncing PRs for repository: $REPO"
    log_info "GitHub username: $USERNAME"
    echo ""

    # Fetch data
    local open_prs=$(fetch_open_prs)
    local existing_tasks=$(get_existing_tasks)

    local open_pr_count=$(echo "$open_prs" | jq 'length')
    local existing_task_count=$(echo "$existing_tasks" | jq 'length')

    log_info "Found $open_pr_count open PRs"
    log_info "Found $existing_task_count existing tasks"
    echo ""

    # Process each open PR
    if [ "$open_pr_count" -gt 0 ]; then
        for i in $(seq 0 $((open_pr_count - 1))); do
            local pr_json=$(echo "$open_prs" | jq ".[$i]")
            process_open_pr "$pr_json" "$existing_tasks"
        done
    fi

    echo ""

    # Handle orphaned tasks
    local open_pr_numbers=$(echo "$open_prs" | jq -r '.[].number')
    handle_orphaned_tasks "$existing_tasks" "$open_pr_numbers"

    echo ""
    log_success "Sync complete!"
}

main "$@"
