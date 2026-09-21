"""Locators: the strings that can name a piece of work.

Parsing is pure, by shape, and says nothing about whether the thing exists
(apart from a directory, whose shape *is* existing). The order of the tests
matters: a uuid must be recognised before anything inside it can be read as an
issue key (…a12e-197… holds "E-197"), and a GitHub URL before the key pattern
can misread a repository called "repo-2".
"""

import os
import re
from dataclasses import dataclass

KINDS = ("task", "pr", "issue", "dir", "window", "branch")

UUID_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I)
GITHUB_URL_RE = re.compile(r"github\.com/([^/\s]+)/([^/\s]+)/(?:pull|issues)/(\d+)")
ISSUE_RE = re.compile(r"^[A-Za-z][A-Za-z0-9]*-\d+$")
# Trackers put the key in the path: …/issue/TEAM-123/some-slug
ISSUE_URL_RE = re.compile(r"^https?://\S+/issue/([A-Za-z][A-Za-z0-9]*-\d+)(?:[/?#]|$)")
# An issue key embedded in something longer, typically a branch name. Anchored
# on both sides so "v2-10" inside a word or a longer number doesn't count.
EMBEDDED_ISSUE_RE = re.compile(r"(?:^|[^A-Za-z0-9])([A-Za-z][A-Za-z0-9]*-\d+)(?:$|[^0-9])")
WINDOW_RE = re.compile(r"^(?:@\d+|[^\s:/]+:[^\s:/]+)$")


@dataclass(frozen=True)
class Locator:
    kind: str
    value: str
    repo: str | None = None


def issue_key_in(text):
    """The issue key carried by a branch name or similar, uppercased."""
    match = EMBEDDED_ISSUE_RE.search(text or "")
    return match.group(1).upper() if match else None


def is_uuid(text):
    return bool(UUID_RE.match(text or ""))


def parse(text, force=None):
    """Turn a string into a Locator. `force` names the kind when the caller
    knows better than the shape (the --task/--pr/… flags)."""
    text = (text or "").strip()
    if not text:
        raise ValueError("empty locator")

    if force:
        if force not in KINDS:
            raise ValueError(f"unknown locator kind: {force}")
        if force == "pr":
            url = GITHUB_URL_RE.search(text)
            if url:
                return Locator("pr", url.group(3), f"{url.group(1)}/{url.group(2)}")
            return Locator("pr", text.lstrip("#"))
        if force == "issue":
            return Locator("issue", (issue_key_in(text) or text).upper())
        if force == "dir":
            return Locator("dir", os.path.realpath(os.path.expanduser(text)))
        return Locator(force, text)

    if is_uuid(text):
        return Locator("task", text.lower())
    url = GITHUB_URL_RE.search(text)
    if url:
        return Locator("pr", url.group(3), f"{url.group(1)}/{url.group(2)}")
    if re.fullmatch(r"#\d+", text):
        return Locator("pr", text[1:])
    if text.isdigit():
        return Locator("task", text)
    if ISSUE_RE.match(text):
        return Locator("issue", text.upper())
    issue_url = ISSUE_URL_RE.match(text)
    if issue_url:
        return Locator("issue", issue_url.group(1).upper())
    if os.path.isdir(os.path.expanduser(text)) and ("/" in text or text in (".", "..", "~")):
        return Locator("dir", os.path.realpath(os.path.expanduser(text)))
    if WINDOW_RE.match(text):
        return Locator("window", text)
    if re.search(r"\s", text):
        raise ValueError(f"not a locator: {text!r}")
    return Locator("branch", text)
