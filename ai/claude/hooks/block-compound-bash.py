#!/usr/bin/env python3
"""PreToolUse hook: block compound Bash commands and git -C.

Reads the Claude Code hook JSON payload from stdin, extracts the Bash
command, and blocks it (exit 2) if it looks like a compound command
(``&&`` / ``;``) or uses ``git -C``. Quoted strings and heredocs are
stripped before checking so that literal operators inside commit
messages and similar do not trigger false positives.
"""

from __future__ import annotations

import json
import re
import sys


def strip_quoted(cmd: str) -> str:
    """Remove single-quoted, double-quoted, and heredoc regions.

    This is a best-effort scanner — not a full shell parser — but it
    handles the common cases that matter for compound-command detection:

    * ``'...'`` single-quoted strings (no escapes)
    * ``"..."`` double-quoted strings (respects ``\\`` escapes; any
      ``$(...)`` inside is skipped as part of the quoted region)
    * ``<<TAG`` / ``<<'TAG'`` / ``<<-TAG`` heredocs
    """
    out: list[str] = []
    i = 0
    n = len(cmd)
    heredoc_re = re.compile(r"<<(-?)\s*(['\"]?)(\w+)\2")

    while i < n:
        c = cmd[i]

        if c == "'":
            j = cmd.find("'", i + 1)
            if j < 0:
                break
            i = j + 1
            continue

        if c == '"':
            j = i + 1
            while j < n:
                if cmd[j] == "\\" and j + 1 < n:
                    j += 2
                    continue
                if cmd[j] == '"':
                    break
                j += 1
            i = j + 1
            continue

        if c == "\\" and i + 1 < n:
            i += 2
            continue

        if c == "<" and i + 1 < n and cmd[i + 1] == "<":
            m = heredoc_re.match(cmd, i)
            if m:
                out.append(m.group(0))
                i = m.end()
                tag = m.group(3)
                strip_tabs = bool(m.group(1))
                nl = cmd.find("\n", i)
                if nl < 0:
                    break
                i = nl + 1
                end_re = re.compile(
                    r"^" + (r"\t*" if strip_tabs else "") + re.escape(tag) + r"\s*$",
                    re.MULTILINE,
                )
                em = end_re.search(cmd, i)
                if not em:
                    break
                i = em.end()
                continue

        out.append(c)
        i += 1

    return "".join(out)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    cmd = (payload.get("tool_input") or {}).get("command") or ""
    if not cmd:
        return 0

    cleaned = strip_quoted(cmd)

    if re.search(r"(^|\s)git\s+-C\b", cleaned):
        print(
            "BLOCKED: Do not use 'git -C'. Run git commands directly "
            "from the working directory (git works from any path in the repo).",
            file=sys.stderr,
        )
        return 2

    if re.search(r"&&|;", cleaned):
        if re.match(r"^\s*cd\s+", cleaned):
            print(
                "BLOCKED: Do not use 'cd ... && ...'. Just run the command "
                "directly, or run 'cd' as a separate Bash tool call if needed.",
                file=sys.stderr,
            )
            return 2
        print(
            "BLOCKED: Compound command detected (contains && or ;). "
            "Run each command as a separate Bash tool call.",
            file=sys.stderr,
        )
        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
