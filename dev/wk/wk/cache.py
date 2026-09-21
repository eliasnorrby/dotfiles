"""Files wk keeps beside taskwarrior.

UDAs are scalar, so per-PR detail (checks, reviewers, labels, stack order)
lives in a cache keyed by task uuid. What sync knew last time lives in the
state directory: it is what lets a sync tell a change from a first sighting,
and what makes staleness visible.
"""

import json
import os

from .config import xdg


def _read(path, default):
    try:
        with open(path, encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, ValueError):
        return default


def _write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    temporary = f"{path}.tmp.{os.getpid()}"
    with open(temporary, "w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=1)
    os.replace(temporary, path)


def prs_path(uuid):
    return os.path.join(xdg("cache"), "prs", f"{uuid}.json")


def read_prs(uuid):
    return _read(prs_path(uuid), [])


def write_prs(uuid, prs):
    if prs:
        if prs != read_prs(uuid):
            _write(prs_path(uuid), prs)
    else:
        try:
            os.remove(prs_path(uuid))
        except OSError:
            pass


def state_path():
    return os.path.join(xdg("state"), "sync.json")


def read_state():
    return _read(state_path(), {})


def write_state(state):
    _write(state_path(), state)
