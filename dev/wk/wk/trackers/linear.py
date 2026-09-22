"""Linear, over its GraphQL API.

API key: $LINEAR_API_KEY, else $XDG_CONFIG_HOME/linear/token.
"""

import json
import os

from ..errors import NotFound, Unreachable, WkError

ENDPOINT = "https://api.linear.app/graphql"
TIMEOUT = 15

ISSUE_QUERY = """
query($team: String!, $number: Float!) {
  issues(filter: { team: { key: { eq: $team } }, number: { eq: $number } }) {
    nodes { identifier title url branchName state { type } parent { identifier } }
  }
}
"""


def token():
    if os.environ.get("LINEAR_API_KEY"):
        return os.environ["LINEAR_API_KEY"]
    base = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    try:
        with open(os.path.join(base, "linear", "token"), encoding="utf-8") as handle:
            return "".join(handle.read().split())
    except OSError:
        return None


def post(query, variables):
    """POST a GraphQL document and return its `data`."""
    import urllib.error
    import urllib.request

    key = token()
    if not key:
        raise WkError("no Linear API key (set $LINEAR_API_KEY or ~/.config/linear/token)")
    request = urllib.request.Request(
        ENDPOINT,
        data=json.dumps({"query": query, "variables": variables}).encode(),
        headers={"Content-Type": "application/json", "Authorization": key},
    )
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            body = json.load(response)
    except urllib.error.HTTPError as err:
        if err.code >= 500:
            raise Unreachable(f"Linear API: HTTP {err.code}") from err
        raise WkError(f"Linear API: HTTP {err.code}") from err
    except (urllib.error.URLError, TimeoutError, OSError) as err:
        raise Unreachable(f"Linear API unreachable: {err}") from err
    if body.get("errors"):
        raise WkError(f"Linear API error: {body['errors'][0].get('message')}")
    return body.get("data") or {}


def fetch_issue(key, post=post):
    """Look an issue up by its key (TEAM-123)."""
    team, _, number = key.rpartition("-")
    data = post(ISSUE_QUERY, {"team": team, "number": int(number)})
    nodes = data.get("issues", {}).get("nodes") or []
    if not nodes:
        raise NotFound(f"issue {key} not found")
    node = nodes[0]
    return {
        "key": node["identifier"],
        "title": node["title"],
        "url": node.get("url"),
        "branch": node.get("branchName"),
        "state": (node.get("state") or {}).get("type"),
        "parent": (node.get("parent") or {}).get("identifier"),
    }


def issue_url(workspace, key, app=False):
    """The issue's address. Linear's own scheme opens the desktop app on
    macOS; on Linux there is no such app, and the web URL is what the PWA
    handler (see wm/handlr) knows how to route."""
    if app:
        return f"linear://{workspace}/issue/{key}"
    return f"https://linear.app/{workspace}/issue/{key}"


CHANGED_QUERY = """
query($filter: IssueFilter!) {
  issues(filter: $filter, first: 250) {
    nodes { identifier title state { type } parent { identifier } }
  }
}
"""


def _by_team(keys):
    teams = {}
    for key in keys:
        team, _, number = key.rpartition("-")
        teams.setdefault(team, []).append(int(number))
    # An explicit `and`: inside an `or`, Linear does not combine the sibling
    # fields of one entry, and the filter silently matches every issue.
    return [{"and": [{"team": {"key": {"eq": team}}}, {"number": {"in": numbers}}]} for team, numbers in teams.items()]


def fetch_changed(keys, since=None, always=(), post=post):
    """Of these issues, the ones updated after `since` (an ISO timestamp; all
    of them when None), plus the `always` ones regardless."""
    queries = []
    if keys:
        changed = {"or": _by_team(keys)}
        if since:
            changed = {"and": [changed, {"updatedAt": {"gt": since}}]}
        queries.append(changed)
    if always and since:
        queries.append({"or": _by_team(always)})
    found = {}
    for issue_filter in queries:
        data = post(CHANGED_QUERY, {"filter": issue_filter})
        for node in data.get("issues", {}).get("nodes") or []:
            found[node["identifier"]] = {
                "key": node["identifier"],
                "title": node["title"],
                "state": (node.get("state") or {}).get("type"),
                "parent": (node.get("parent") or {}).get("identifier"),
            }
    return list(found.values())
