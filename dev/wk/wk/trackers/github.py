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


# -- sync --------------------------------------------------------------------

# Two small repo-scoped searches in one request. A single broad one times out
# (HTTP 504), and an unscoped review search drags in every repository that
# ever asked, so the repo list is required.
PAGE_MINE = 50
PAGE_REVIEW = 30

OPEN_QUERY = """
query($mine: String!, $review: String!, $after: String) {
  viewer { login }
  mine: search(query: $mine, type: ISSUE, first: PAGE_MINE, after: $after) {
    issueCount pageInfo { hasNextPage endCursor } nodes { ...pr }
  }
  review: search(query: $review, type: ISSUE, first: PAGE_REVIEW) {
    issueCount nodes { ...pr }
  }
}
fragment pr on PullRequest {
  id number title url isDraft mergeable
  repository { nameWithOwner } author { login }
  headRefName baseRefName reviewDecision
  latestOpinionatedReviews(first: 10) { nodes { state author { login } } }
  reviewRequests(first: 10) { nodes { requestedReviewer { __typename ... on User { login } ... on Team { slug } } } }
  commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
  labels(first: 10) { nodes { name } }
}
""".replace("PAGE_MINE", str(PAGE_MINE)).replace("PAGE_REVIEW", str(PAGE_REVIEW))

STATES_QUERY = """
query($ids: [ID!]!) {
  nodes(ids: $ids) { ... on PullRequest { id number state repository { nameWithOwner } } }
}
"""


def _graphql(query, variables, run):
    args = ["api", "graphql", "-f", f"query={query}"]
    for name, value in variables.items():
        if isinstance(value, list):
            args += [item for entry in value for item in ("-f", f"{name}[]={entry}")]
        elif value is not None:
            args += ["-f", f"{name}={value}"]
    try:
        body = json.loads(gh(args, run))
    except WkError as err:
        # gh reports gateway errors (502/504) as plain failures; for a sync
        # they mean "stale", not "broken".
        if any(code in str(err) for code in ("HTTP 502", "HTTP 503", "HTTP 504")):
            raise Unreachable(str(err)) from err
        raise
    if body.get("errors"):
        raise WkError(f"GitHub API error: {body['errors'][0].get('message')}")
    return body["data"]


def _normalise(node):
    commits = (node.get("commits") or {}).get("nodes") or []
    rollup = (commits[0]["commit"].get("statusCheckRollup") or {}) if commits else {}
    reviews = (node.get("latestOpinionatedReviews") or {}).get("nodes") or []
    requests = (node.get("reviewRequests") or {}).get("nodes") or []
    return {
        "id": node["id"],
        "number": str(node["number"]),
        "title": node["title"],
        "url": node["url"],
        "repo": node["repository"]["nameWithOwner"],
        "author": (node.get("author") or {}).get("login"),
        "head": node["headRefName"],
        "base": node["baseRefName"],
        "draft": node["isDraft"],
        "mergeable": node.get("mergeable"),
        "decision": node.get("reviewDecision"),
        "checks": rollup.get("state"),
        "labels": [label["name"] for label in (node.get("labels") or {}).get("nodes") or []],
        "reviews": [{"login": (r.get("author") or {}).get("login"), "state": r["state"]} for r in reviews],
        "requested": [
            (r.get("requestedReviewer") or {}).get("login") or (r.get("requestedReviewer") or {}).get("slug")
            for r in requests
        ],
    }


def fetch_open(repos, team_requests=False, run=subprocess.run):
    """My open PRs and the open PRs waiting for my review, in `repos`.
    Returns (mine, review, complete): `complete` is False when a result was
    cut short, in which case a PR's absence proves nothing."""
    if not repos:
        raise WkError('no repositories to sync: set `sync = true` on a [repos."owner/name"] table')
    scope = " ".join(f"repo:{repo}" for repo in repos)
    requested = "review-requested" if team_requests else "user-review-requested"
    variables = {
        "mine": f"is:pr is:open author:@me archived:false {scope}",
        "review": f"is:pr is:open {requested}:@me archived:false {scope}",
    }
    data = _graphql(OPEN_QUERY, variables, run)
    mine = [_normalise(node) for node in data["mine"]["nodes"] if node]
    review = [_normalise(node) for node in data["review"]["nodes"] if node]
    complete = data["review"]["issueCount"] <= PAGE_REVIEW
    page = data["mine"]["pageInfo"]
    while page["hasNextPage"]:
        more = _graphql(OPEN_QUERY, {**variables, "after": page["endCursor"]}, run)
        mine += [_normalise(node) for node in more["mine"]["nodes"] if node]
        page = more["mine"]["pageInfo"]
    login = data["viewer"]["login"]
    return mine, [pr for pr in review if pr["author"] != login], complete


def fetch_states(node_ids, run=subprocess.run):
    """What became of PRs that left the open set: {node id: MERGED|CLOSED|OPEN}."""
    if not node_ids:
        return {}
    data = _graphql(STATES_QUERY, {"ids": list(node_ids)}, run)
    return {node["id"]: node["state"] for node in data["nodes"] if node}


def fetch_state(number, repo, run=subprocess.run):
    """The same for a PR never seen by a sync (attached by hand or by a hook)."""
    data = json.loads(gh(["pr", "view", str(number), "--repo", repo, "--json", "id,state"], run))
    return data["id"], data["state"]
