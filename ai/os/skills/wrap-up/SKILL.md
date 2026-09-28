---
name: wrap-up
description: End the work on this session's task so the session can be quit: a last checkpoint into the wiki with the note readable cold, what remains filed as follow-up tasks, and the task closed (or paused with `later`, or dropped). Use when the user says "wrap up", "we're done", "close this", "let's stop here", or invokes /wrap-up.
---

Close the loop on this session's task. Three steps, in order, and a few
lines at the end saying what happened. `$ARGUMENTS` may be empty (close the
task), `later` (pause it: the work goes on another day) or `dropped` (it
won't be done).

## 1. Where things stand

```
wiki_checkpoint resolve
```

from the directory the work happened in. It prints the task's uuid, its
vault and its note. Exit 2 means wk knows no task for this session: there is
nothing to close, say so and stop. Exit 3 (a vault without a schema): close
the task in step 3 and skip step 2.

Then look, without changing anything:

- `git status --short` in the working directory, unless it is a vault or
  `~/os`. Uncommitted work is reported to the user, never committed or
  stashed on your own: a worktree that gets removed later takes it along.
- Anything the conversation left hanging: a PR waiting for review, a
  question the user never answered, a check that was going to happen later.
  These become follow-ups in step 2 or a line in the report.

## 2. The last checkpoint

Run the `wiki-checkpoint` skill's steps, written for someone who opens the
note cold in a month:

- **Summary** says, in the past tense, what was done, what it changed, and
  what remains. Two or three sentences.
- **Plan** has no loose items: each one is ticked, struck through with a
  word on why, or moved to a follow-up (`- [ ] … → [[<follow-up note>]]`).
- **Decisions**, **Findings**, **Links** and **Wiki use** as the checkpoint
  skill says. Knowledge that outlives the task goes onto its page or under
  `## Wanted` in `index.md`; a task note gets archived, the index doesn't.
- **Follow-ups.** Each piece of work that remains and is worth tracking
  becomes a task in the same project, with its own note holding what a fresh
  session needs (why, where to start, a link back to this note):

  ```
  task add project:<project> "<description>"     # prints "Created task N."
  wk note --print --task N                        # creates the note, prints its path
  ```

  Then write the note. When it isn't clear whether the user wants something
  tracked, ask, with the AskUserQuestion tool; a check he'll do in passing
  ("see if the chime is audible") is a line in the report, not a task.
- Commit exactly the files you touched with `wiki_checkpoint commit`, then
  `wiki_checkpoint mark`.

## 3. Close the task

The note's `status` and its move to `archive/` are wk's job, through a
taskwarrior hook; never set or move them yourself.

Work that goes out as a PR closes itself: `wk sync` completes the task when
its PR merges. So when `task _get <uuid>.prs` names a PR that is still
open, don't mark the task done; checkpoint, `task <uuid> stop`, and say
that wk closes it on merge. The rest, tasks without PRs (OS and personal
work, investigations, spikes), is what this step is for:

- No argument: `task <uuid> done`.
- `later`: `task <uuid> stop`. The task stays pending and its note active;
  the Summary says where to pick up.
- `dropped`: confirm with the user, then `task <uuid> delete`; the Summary
  says why it was dropped.

Then tell the user the session can be quit: closing it frees the tmux
window, and the SessionEnd hook leaves its trail. Don't start another task
here unless asked; a new piece of work gets `wk adopt` in a new session.

## Never

Commit or push repositories, merge or close PRs, touch other tasks, or move
notes between folders. Those are the user's calls, or wk's.
