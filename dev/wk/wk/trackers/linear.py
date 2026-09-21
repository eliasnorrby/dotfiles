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
    nodes { identifier title url state { type } parent { identifier } }
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
        "state": (node.get("state") or {}).get("type"),
        "parent": (node.get("parent") or {}).get("identifier"),
    }


def app_url(workspace, key):
    """Linear's custom scheme, which opens the desktop app directly."""
    return f"linear://{workspace}/issue/{key}"
