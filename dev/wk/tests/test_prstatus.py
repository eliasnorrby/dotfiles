from wk import prstatus


def pr(number, head="h", base="main", **fields):
    return {"number": str(number), "repo": "acme/app", "head": head, "base": base, "title": "t", **fields}


def test_status_of_one_pr():
    assert prstatus.status_of(pr(1)) == "review"
    assert prstatus.status_of(pr(1, decision="APPROVED", checks="SUCCESS")) == "approved"
    assert prstatus.status_of(pr(1, decision="APPROVED", checks="PENDING")) == "approved"
    assert prstatus.status_of(pr(1, decision="APPROVED", checks="FAILURE")) == "failing"
    assert prstatus.status_of(pr(1, mergeable="CONFLICTING")) == "failing"
    assert prstatus.status_of(pr(1, decision="CHANGES_REQUESTED")) == "changes"
    assert prstatus.status_of(pr(1, draft=True)) == "draft"
    assert prstatus.status_of(pr(1, draft=True, checks="ERROR")) == "failing"


def test_the_worst_wins_and_draft_ranks_lowest():
    assert prstatus.aggregate([pr(1, decision="APPROVED"), pr(2, checks="FAILURE")]) == "failing"
    assert prstatus.aggregate([pr(1, draft=True), pr(2)]) == "review"
    assert prstatus.aggregate([pr(1, draft=True), pr(2, draft=True)]) == "draft"
    assert prstatus.aggregate([]) == ""


def test_stack_order_follows_base_branches():
    stack = [pr(79, "d", "c"), pr(72, "a"), pr(78, "c", "b"), pr(77, "b", "a"), pr(80, "solo")]
    assert [p["number"] for p in prstatus.stack_order(stack)] == ["72", "77", "78", "79", "80"]


def test_a_cycle_falls_back_to_number():
    assert [p["number"] for p in prstatus.stack_order([pr(2, "a", "b"), pr(1, "b", "a")])] == ["1", "2"]
