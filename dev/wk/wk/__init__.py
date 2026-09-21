"""wk: taskwarrior as the hub for issues, PRs, worktrees, windows and notes.

The taskwarrior task, by uuid, is the identity of a piece of work; everything
else is an attribute of it. Standard library only, and every module imports
its heavier dependencies lazily: hooks run this on every prompt and every
`task modify`, so start-up time is part of the interface.
"""
