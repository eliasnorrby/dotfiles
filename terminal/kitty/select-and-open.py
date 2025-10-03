import re
import os
import subprocess


def get_repository_url():
    default_repository = "https://github.com/eliasnorrby/dotfiles"

    bin_dir = os.environ.get("XDG_BIN_HOME", os.path.expanduser("~/.local/bin"))
    repository = subprocess.run(
        [f"{bin_dir}/get_pr_repository_url"], capture_output=True, text=True
    )

    if repository.returncode != 0:
        return default_repository

    return repository.stdout.strip()


def mark(text, args, Mark, extra_cli_args, *a):
    for idx, m in enumerate(re.finditer(r"(#\d+|BEMLO-\d+)", text)):
        start, end = m.span()
        mark_text = text[start:end].replace("\n", "").replace("\0", "")
        yield Mark(idx, start, end, mark_text, {})


def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    match = data["match"][0]
    if match.startswith("BEMLO-"):
        # This is a Linear issue ID
        issue_id = match
        linear_base_url = "https://linear.app/bemlo"
        boss.open_url(f"{linear_base_url}/issue/{issue_id}")
        return
    if match.startswith("#"):
        # This is a GitHub issue number
        if match[1:].isdigit():
            number = match[1:]
            repository_url = get_repository_url()
            boss.open_url(f"{repository_url}/pull/{number}")
