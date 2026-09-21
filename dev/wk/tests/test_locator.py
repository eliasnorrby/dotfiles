import pytest

from wk.locator import Locator, issue_key_in, parse

UUID = "0b1c2d3e-a12e-197a-8b9c-0d1e2f3a4b5c"


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        (UUID, Locator("task", UUID)),
        ("63", Locator("task", "63")),
        ("#10871", Locator("pr", "10871")),
        ("https://github.com/acme/repo-2/pull/77", Locator("pr", "77", "acme/repo-2")),
        ("https://github.com/acme/app/issues/5", Locator("pr", "5", "acme/app")),
        ("ACME-123", Locator("issue", "ACME-123")),
        ("acme-123", Locator("issue", "ACME-123")),
        ("https://linear.app/acme/issue/ACME-123/fix-v2-thing", Locator("issue", "ACME-123")),
        ("@4", Locator("window", "@4")),
        ("app:3", Locator("window", "app:3")),
        ("someone/acme-12-fix-the-thing", Locator("branch", "someone/acme-12-fix-the-thing")),
        ("someone/replace-the-feature", Locator("branch", "someone/replace-the-feature")),
    ],
)
def test_shape_decides(text, expected):
    assert parse(text) == expected


def test_a_uuid_is_never_read_as_the_issue_key_inside_it():
    # …a12e-197… would otherwise parse as issue E-197.
    assert parse(UUID).kind == "task"


def test_an_existing_directory_is_a_directory(tmp_path):
    assert parse(str(tmp_path)) == Locator("dir", str(tmp_path.resolve()))


def test_flags_force_a_kind():
    assert parse("63", force="pr") == Locator("pr", "63")
    assert parse("ACME-1", force="branch") == Locator("branch", "ACME-1")
    assert parse("someone/acme-12-fix", force="issue") == Locator("issue", "ACME-12")


@pytest.mark.parametrize("text", ["", "   ", "some words here"])
def test_not_a_locator(text):
    with pytest.raises(ValueError):
        parse(text)


@pytest.mark.parametrize(
    ("branch", "key"),
    [
        ("someone/acme-12-fix-the-thing", "ACME-12"),
        ("ACME-12", "ACME-12"),
        ("acme-12", "ACME-12"),
        ("someone/replace-the-feature", None),
        ("main", None),
    ],
)
def test_issue_key_in_a_branch(branch, key):
    assert issue_key_in(branch) == key
