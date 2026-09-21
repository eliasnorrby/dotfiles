---
name: delegate
description: Hand sub-issues (or other separable pieces of work) to their own interactive Claude sessions, each in its own worktree and tmux window, instead of doing them all in this conversation. Use when an issue fans out into sub-issues, when a review turns up work that deserves its own PR and thread, or when the user says "delegate", "branch this out" or "spin up sessions for these".
---

Split work across separate interactive sessions that the user can walk up to.

The contract this protects: one issue, one worktree, one conversation. Work
done for a sub-issue inside its parent's thread is hard to find again later.

## 1. Ask how to proceed

When an issue turns out to span several sub-issues, don't decide alone. Ask
with AskUserQuestion:

- **Work through them here** (alone or with sub-agents). Right for small,
  tightly coupled pieces, or a preparatory PR stacked under the one at hand.
- **Interactive branching**: a window per sub-issue, each with its own
  interactive Claude session. Right when the pieces are independent enough to
  be reviewed, resumed and reasoned about on their own.

## 2. Branch out

For each piece, one command. It imports the issue if needed, creates the note,
the worktree and the tmux window, and starts Claude there with a first prompt:

```
wk start <ISSUE-KEY> --partof <PARENT-KEY> --no-switch --json
```

- `--partof` records the parent on the new task, so the pieces stay findable
  from the investigation they came from.
- `--no-switch` leaves the user where they are. Drop it for the one piece they
  want to look at first.
- The first prompt defaults to the configured one (usually `/lg`, which reads
  the issue and interviews the user before writing code). Pass
  `--prompt '<text>'` when the session needs context the issue lacks: what you
  found, which approach was agreed, what to stay out of.
- For a piece without an issue: `wk start --new "<description>" --on <branch>`.

The sessions are interactive on purpose. Do not try to drive them, wait for
them or collect their output: the user talks to each one.

## 3. Report back

Tell the user, in a short list, what was started and where (the `session` and
`window` fields of each result). Their task list shows each session's state
(working, waiting for input, idle), and they are notified when one needs them.

Then continue with whatever remains yours in this conversation, and checkpoint:
the parent's task note should say which pieces were handed off.
