"""
Kitty Hints Script: Select and Open Issues

This script enables kitty hints for GitHub pull requests and Linear issues.
It allows you to select issue/PR references in terminal output and open them
in your browser or native app.

Supported patterns:
- GitHub PRs: #123 (opens in browser)
- Linear issues: BEMLO-123 (opens in Linear app via universal link)

Usage:
Add to your kitty.conf:
    map kitty_mod+p kitten hints --type=regex --regex="(#\\d+|BEMLO-\\d+)" --program=@

Configuration is available at the top of this file.
"""

import re
import os
import platform
import subprocess

# ============================================================================
# Configuration
# ============================================================================

# GitHub configuration
DEFAULT_GITHUB_REPOSITORY = "https://github.com/eliasnorrby/dotfiles"

# Linear configuration
LINEAR_TEAM = "bemlo"
LINEAR_ISSUE_PATTERN = r"BEMLO-\d+"

# GitHub PR pattern
GITHUB_PR_PATTERN = r"#\d+"

# Combined regex pattern for matching
MATCH_PATTERN = rf"({GITHUB_PR_PATTERN}|{LINEAR_ISSUE_PATTERN})"

# ============================================================================
# Helper Functions
# ============================================================================


def get_repository_url():
    """Get the GitHub repository URL from get_pr_repository_url script or use default."""
    bin_dir = os.environ.get("XDG_BIN_HOME", os.path.expanduser("~/.local/bin"))
    repository = subprocess.run(
        [f"{bin_dir}/get_pr_repository_url"], capture_output=True, text=True
    )

    if repository.returncode != 0:
        return DEFAULT_GITHUB_REPOSITORY

    return repository.stdout.strip()


# ============================================================================
# Kitty Hints Functions
# ============================================================================


def mark(text, _args, Mark, _extra_cli_args, *_rest):
    """Mark all GitHub PR and Linear issue references in the text."""
    for idx, m in enumerate(re.finditer(MATCH_PATTERN, text)):
        start, end = m.span()
        mark_text = text[start:end].replace("\n", "").replace("\0", "")
        yield Mark(idx, start, end, mark_text, {})


def handle_result(_args, data, _target_window_id, boss, _extra_cli_args, *_rest):
    """Handle the selected match by opening the appropriate URL."""
    match = data["match"][0]

    # Check if it's a Linear issue
    if re.match(LINEAR_ISSUE_PATTERN, match):
        issue_id = match
        if platform.system() == "Darwin":
            # macOS: linear:// deep link opens the native Linear app directly.
            url = f"linear://{LINEAR_TEAM}/issue/{issue_id}"
        else:
            # Linux: linear:// is unregistered, so emit the universal link and
            # let handlr route it to the PWA (see wm/handlr/linear-open.sh).
            url = f"https://linear.app/{LINEAR_TEAM}/issue/{issue_id}"
        boss.open_url(url)
        return

    # Check if it's a GitHub PR
    if match.startswith("#"):
        if match[1:].isdigit():
            number = match[1:]
            repository_url = get_repository_url()
            boss.open_url(f"{repository_url}/pull/{number}")
