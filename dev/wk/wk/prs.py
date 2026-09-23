"""What a pull request means for the work item carrying it. Pure.

Three attributes, each with a direction, so that the sum sorts the task list
without anyone enumerating the cases:

  action    the verb, for me: merge, fix, review, assign, finish, await
            (not "wait", which is an attribute name and so a reference)
  decision  where the PR stands: approved, changes, draft
  health    what is red: failing (checks), conflict

Whose PR it is decides what red turns into. On mine, red means the next
action is `fix`; on one I am asked to review, the action stays `review` and
the red state just makes it a worse one to pick up right now. A task with
several PRs carries the attributes of the one most in need of me.
"""

# Most in need of me first.
ACTIONS = ("merge", "fix", "review", "assign", "finish", "await")
DECISIONS = ("approved", "changes", None, "draft")
HEALTH = (None, "failing", "conflict")


def health_of(pr):
    if pr.get("mergeable") == "CONFLICTING":
        return "conflict"
    if pr.get("checks") in ("FAILURE", "ERROR"):
        return "failing"
    return None


def decision_of(pr):
    if pr.get("decision") == "APPROVED":
        return "approved"
    if pr.get("decision") == "CHANGES_REQUESTED":
        return "changes"
    if pr.get("draft"):
        return "draft"
    return None


def classify(pr, mine=True):
    """The three attributes of one PR. Pending checks have no value of their
    own (they show in the picker instead): a value that flips with every CI
    run would mean a `task modify` per run."""
    health = health_of(pr)
    decision = decision_of(pr)
    if not mine:
        # Another reviewer's verdict says nothing about how much my review
        # is needed; that it is still a draft does.
        return {"action": "review", "decision": decision if decision == "draft" else None, "health": health}
    if decision == "approved" and not health:
        action = "merge"
    elif health or decision == "changes":
        action = "fix"
    elif decision == "draft":
        action = "finish"
    elif pr.get("requested") or pr.get("reviews"):
        action = "await"
    else:
        action = "assign"
    return {"action": action, "decision": decision, "health": health}


def rank(attributes):
    return (
        ACTIONS.index(attributes["action"]),
        DECISIONS.index(attributes["decision"]),
        HEALTH.index(attributes["health"]),
    )


def aggregate(prs, mine=True):
    """The attributes of the PR most in need of me; empty when there is none."""
    if not prs:
        return {"action": None, "decision": None, "health": None}
    return min((classify(pr, mine) for pr in prs), key=rank)


def stack_order(prs):
    """Bottom of the stack first: a PR's parent is the PR whose head branch is
    its base. Anything that isn't a clean forest falls back to PR number."""
    by_number = sorted(prs, key=lambda pr: int(pr["number"]))
    by_head = {(pr.get("repo"), pr.get("head")): pr for pr in by_number}
    children = {}
    roots = []
    for pr in by_number:
        parent = by_head.get((pr.get("repo"), pr.get("base")))
        if parent is not None and parent is not pr:
            children.setdefault(id(parent), []).append(pr)
        else:
            roots.append(pr)

    ordered, seen = [], set()

    def visit(pr):
        if id(pr) in seen:
            return
        seen.add(id(pr))
        ordered.append(pr)
        for child in children.get(id(pr), []):
            visit(child)

    for root in roots:
        visit(root)
    # A cycle has no root; whatever it left out goes last, by number.
    return ordered + [pr for pr in by_number if id(pr) not in seen]


def summary(pr, mine=True):
    """One line for a picker."""
    if pr.get("state") in ("MERGED", "CLOSED"):
        return f"#{pr['number']}  {pr['state'].lower():<7}           {pr.get('title', '')}"
    attributes = classify(pr, mine)
    checks = {"SUCCESS": "✓", "FAILURE": "✗", "ERROR": "✗", "PENDING": "…", "EXPECTED": "…"}.get(pr.get("checks"), " ")
    note = " ".join(filter(None, [attributes["decision"], attributes["health"]]))
    return f"#{pr['number']}  {attributes['action']:<7} {checks} {note:<17} {pr.get('title', '')}"
