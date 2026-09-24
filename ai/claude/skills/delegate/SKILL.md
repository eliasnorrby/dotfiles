---
name: delegate
description: Hand sub-issues (or other separable pieces of work) to their own Claude sessions or to background agents, each with its own task, note and PR, instead of doing them all in this conversation. Use when an issue fans out into sub-issues, when a review turns up work that deserves its own PR and thread, when the user asks for sub-agents per sub-issue, or when the user says "delegate", "branch this out" or "spin up sessions for these".
---

Split work so each piece stays findable: its own task, note, branch and PR.

The contract this protects: one issue, one task, one note, one PR trail. Work
done for a sub-issue inside its parent's thread is hard to find again later
unless it is recorded against the sub-issue.

## 1. Ask how to proceed

When an issue turns out to span several sub-issues, don't decide alone. Ask
with AskUserQuestion (skip it when the user already said which):

- **Work through them here.** Right for small, tightly coupled pieces, or a
  preparatory PR stacked under the one at hand. No new tasks.
- **Background agents**: one agent of this session per sub-issue, each with
  its own task, note and PR. Right when the pieces are well understood and
  the user wants them done, not talked through. Continue with section 2.
- **Interactive branching**: a window per sub-issue, each with its own
  interactive Claude session. Right when the pieces need their own
  conversation with the user. Continue with section 3.

## 2. Background agents

For each piece, first give it a task, from here:

```
wk start <ISSUE-KEY> --partof <PARENT-KEY> --background --json
```

It imports the issue if needed, creates the note, names the branch and ties
the task to this session, without a worktree or a window. The result holds
`branch`, `note` (the task note's path) and `repository` (the main checkout).
For a piece without an issue: `wk start --new "<description>" --background`.

What follows from it, so don't do any of this by hand:

- The PR an agent opens is attached to its sub-task by the branch.
- The sub-task stays out of the user's task list. The parent stands for it,
  listing its PRs and taking on their status.
- Opening the sub-task (`o` in the task list) leads to this session's window
  while this session runs.

Then start one Agent per piece with `isolation: "worktree"`, all in one
message so they run in parallel. Claude makes and cleans up those checkouts;
wk's `.worktrees/` are for interactive sessions only. Each agent's prompt
carries what it cannot find out alone:

- the issue key, the task note's path, and what you already know: findings,
  the agreed approach, what to stay out of;
- to switch its checkout to the branch before anything else, from the right
  base (`git switch -c <branch> <base>`; the parent's branch when the pieces
  stack on it, else the default branch);
- to push and open the PR with `gh pr create`;
- to record its work in its task note only (the vault's `CLAUDE.md` says how)
  and commit just that file with
  `wiki_checkpoint commit "<vault>" -- "<note>"`. Other agents are writing to
  the same vault at the same time: the daily note, `index.md` and the
  parent's note are yours, not theirs. If it runs `wiki_checkpoint resolve`,
  it must pass `--issue <ISSUE-KEY>`: without it, it finds the parent, whose
  window it runs in;
- to report back the PR, what it did, and anything left open.

When they report, check the PRs, then checkpoint: the parent's task note
lists the pieces and their PRs, and today's daily gets the bullets.

## 3. Interactive branching

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

Tell the user, in a short list, what was started and where (the `session` and
`window` fields of each result). Their task list shows each session's state
(working, waiting for input, idle), and they are notified when one needs them.

Then continue with whatever remains yours in this conversation, and checkpoint:
the parent's task note should say which pieces were handed off.
