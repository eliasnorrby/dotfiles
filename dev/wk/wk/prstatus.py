"""What a pull request's state means for the work item carrying it. Pure.

A task can carry a whole stack, but has one `prstatus`: the worst across its
PRs, because the worst one is what needs attention.
"""

# Worst first. Draft ranks lowest on purpose: a stack with one draft and one
# PR awaiting review is "waiting on review"; it reads "draft" only when every
# PR is one.
ORDER = ("failing", "changes", "review", "approved", "draft")


def status_of(pr):
    """One PR's status. Pending checks have no value of their own (they show
    in the picker instead): a value that flips with every CI run would mean a
    `task modify` per run."""
    if pr.get("checks") in ("FAILURE", "ERROR") or pr.get("mergeable") == "CONFLICTING":
        return "failing"
    if pr.get("decision") == "CHANGES_REQUESTED":
        return "changes"
    if pr.get("draft"):
        return "draft"
    if pr.get("decision") == "APPROVED":
        return "approved"
    return "review"


def aggregate(prs):
    statuses = {status_of(pr) for pr in prs}
    return next((status for status in ORDER if status in statuses), "")


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


def summary(pr):
    """One line for a picker."""
    if pr.get("state") in ("MERGED", "CLOSED"):
        return f"#{pr['number']}  {pr['state'].lower():<8}    {pr.get('title', '')}"
    checks = {"SUCCESS": "✓", "FAILURE": "✗", "ERROR": "✗", "PENDING": "…", "EXPECTED": "…"}.get(pr.get("checks"), " ")
    conflict = " conflict" if pr.get("mergeable") == "CONFLICTING" else ""
    return f"#{pr['number']}  {status_of(pr):<8} {checks}{conflict}  {pr.get('title', '')}"
