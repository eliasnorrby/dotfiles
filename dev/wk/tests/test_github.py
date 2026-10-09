from wk.trackers.github import checks_of


def rollup(state, *contexts, total=None):
    total = len(contexts) if total is None else total
    return {"state": state, "contexts": {"totalCount": total, "nodes": list(contexts)}}


def run(conclusion, status="COMPLETED"):
    return {"status": status, "conclusion": conclusion}


def status(state):
    return {"state": state}


def test_github_word_stands_unless_it_says_failure():
    assert checks_of({}) is None
    assert checks_of(rollup("SUCCESS", run("CANCELLED"))) == "SUCCESS"
    assert checks_of(rollup("PENDING", run(None, "IN_PROGRESS"))) == "PENDING"
    assert checks_of(rollup("FAILURE")) == "FAILURE"


def test_a_cancelled_run_is_not_a_failure():
    # Self-review's `cancel-in-progress` kills the older of two runs; GitHub
    # rolls that up as FAILURE, and nobody has anything to fix.
    assert checks_of(rollup("FAILURE", run("CANCELLED"), run("SUCCESS"), status("SUCCESS"))) == "SUCCESS"
    assert checks_of(rollup("FAILURE", run("SKIPPED"), run("NEUTRAL"), run("STALE"))) == "SUCCESS"


def test_a_real_failure_still_counts():
    assert checks_of(rollup("FAILURE", run("CANCELLED"), run("FAILURE"))) == "FAILURE"
    assert checks_of(rollup("FAILURE", run("CANCELLED"), status("ERROR"))) == "FAILURE"
    assert checks_of(rollup("FAILURE", run("TIMED_OUT"))) == "FAILURE"


def test_cancelled_beside_unfinished_is_pending():
    assert checks_of(rollup("FAILURE", run("CANCELLED"), run(None, "IN_PROGRESS"))) == "PENDING"
    assert checks_of(rollup("FAILURE", run("CANCELLED"), status("PENDING"))) == "PENDING"
    assert checks_of(rollup("FAILURE", run("CANCELLED"), run("ACTION_REQUIRED"))) == "PENDING"


def test_truncated_contexts_keep_githubs_word():
    assert checks_of(rollup("FAILURE", run("CANCELLED"), total=101)) == "FAILURE"
