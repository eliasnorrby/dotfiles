"""Errors, carrying the exit status they map to.

0 resolved, 2 nothing recognisable or nothing found, 1 recognised but failed,
3 resolved but the vault has no wiki schema. Callers such as wiki_checkpoint
branch on these.
"""


class WkError(Exception):
    code = 1
    name = "failed"


class NotFound(WkError):
    code = 2
    name = "not_found"


class Unreachable(WkError):
    """The network, or the service behind it, could not be reached."""

    name = "unreachable"
