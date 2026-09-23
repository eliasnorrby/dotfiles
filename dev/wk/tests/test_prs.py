from wk import prs


def pr(number, head="h", base="main", **fields):
    return {"number": str(number), "repo": "acme/app", "head": head, "base": base, "title": "t", **fields}


def attrs(action, decision=None, health=None):
    return {"action": action, "decision": decision, "health": health}


def test_my_prs_get_the_verb_i_owe_them():
    assert prs.classify(pr(1)) == attrs("assign")
    assert prs.classify(pr(1, requested=["them"])) == attrs("await")
    assert prs.classify(pr(1, reviews=[{"login": "them", "state": "COMMENTED"}])) == attrs("await")
    assert prs.classify(pr(1, decision="APPROVED", checks="SUCCESS")) == attrs("merge", "approved")
    assert prs.classify(pr(1, decision="APPROVED", checks="PENDING")) == attrs("merge", "approved")
    assert prs.classify(pr(1, decision="APPROVED", checks="FAILURE")) == attrs("fix", "approved", "failing")
    assert prs.classify(pr(1, decision="APPROVED", mergeable="CONFLICTING")) == attrs("fix", "approved", "conflict")
    assert prs.classify(pr(1, decision="CHANGES_REQUESTED")) == attrs("fix", "changes")
    assert prs.classify(pr(1, draft=True)) == attrs("finish", "draft")
    assert prs.classify(pr(1, draft=True, mergeable="CONFLICTING")) == attrs("fix", "draft", "conflict")
    assert prs.classify(pr(1, requested=["them"], checks="ERROR")) == attrs("fix", None, "failing")


def test_their_prs_are_always_a_review_whatever_their_state():
    assert prs.classify(pr(1, requested=["me"]), mine=False) == attrs("review")
    assert prs.classify(pr(1, requested=["me"], checks="FAILURE"), mine=False) == attrs("review", None, "failing")
    assert prs.classify(pr(1, draft=True, mergeable="CONFLICTING"), mine=False) == attrs("review", "draft", "conflict")
    assert prs.classify(pr(1, decision="APPROVED"), mine=False) == attrs("review")


def test_the_pr_most_in_need_of_me_speaks_for_the_task():
    assert prs.aggregate([pr(1, requested=["them"]), pr(2, checks="FAILURE")])["action"] == "fix"
    assert prs.aggregate([pr(1, draft=True), pr(2, requested=["them"])])["action"] == "finish"
    assert prs.aggregate([pr(1, draft=True), pr(2)])["action"] == "assign"
    both = prs.aggregate([pr(1, decision="APPROVED"), pr(2, decision="APPROVED", checks="FAILURE")])
    assert both == attrs("merge", "approved")
    assert prs.aggregate([]) == attrs(None)


def test_stack_order_follows_base_branches():
    stack = [pr(79, "d", "c"), pr(72, "a"), pr(78, "c", "b"), pr(77, "b", "a"), pr(80, "solo")]
    assert [p["number"] for p in prs.stack_order(stack)] == ["72", "77", "78", "79", "80"]


def test_a_cycle_falls_back_to_number():
    assert [p["number"] for p in prs.stack_order([pr(2, "a", "b"), pr(1, "b", "a")])] == ["1", "2"]
