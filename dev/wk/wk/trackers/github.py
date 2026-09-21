"""GitHub, through the gh CLI (which owns authentication)."""

import json
import subprocess

from ..errors import NotFound, Unreachable, WkError

TIMEOUT = 20


def gh(args, run=subprocess.run, cwd=None):
    try:
        result = run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
            cwd=cwd,
            stdin=subprocess.DEVNULL,
        )
    except FileNotFoundError as err:
        raise WkError("gh is not installed") from err
    except subprocess.TimeoutExpired as err:
        raise Unreachable("gh timed out") from err
    if result.returncode != 0:
        message = result.stderr.strip()
        lowered = message.lower()
        if any(hint in lowered for hint in ("could not resolve", "connection", "timeout", "dial tcp")):
            raise Unreachable(message)
        raise WkError(message or f"gh {' '.join(args)} failed")
    return result.stdout


def fetch_pr(number, repo=None, run=subprocess.run, cwd=None):
    """Title and repository of a PR, falling back to an issue of that number.
    The repository is inferred from `cwd` when not given."""
    fields = "number,title,url"
    scope = ["--repo", repo] if repo else []
    try:
        data = json.loads(gh(["pr", "view", str(number), "--json", fields + ",headRefName"] + scope, run, cwd))
    except Unreachable:
        raise
    except WkError:
        try:
            data = json.loads(gh(["issue", "view", str(number), "--json", fields] + scope, run, cwd))
        except Unreachable:
            raise
        except WkError as err:
            raise NotFound(f"GitHub #{number} not found (is gh authenticated and in a repo?)") from err
    if not repo:
        # Name the inferred repo explicitly so the task can record it.
        repo = gh(["repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"], run, cwd).strip()
    return {
        "number": str(data["number"]),
        "title": data["title"],
        "url": data.get("url"),
        "repo": repo,
        "branch": data.get("headRefName"),
    }
