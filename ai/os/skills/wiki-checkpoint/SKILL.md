---
name: wiki-checkpoint
description: Record where the current work stands in the user's LLM-maintained wiki (task note, today's daily, and hubs or pages when something durable was learned). Invoke it yourself, without being asked, when a requirement or design decision is settled, an approach is abandoned, an investigation reaches a conclusion, a PR is opened or merged, before ending a work session, or when a hook reminds you to. Also when the user says "checkpoint", "log this" or "update the wiki".
---

Checkpoint this session into the wiki. You already hold the context, so this
should be quick: a few targeted edits, not a re-read of the conversation. Don't
interrupt the task at hand for it; do it at a natural pause, and mention it to
the user in one line at most.

## 1. Find where it goes

```
wiki_checkpoint resolve
```

Run it from the directory the work is happening in. It prints `issue`, `task`,
`vault` and `note` (the task note, created if it didn't exist, along with the
taskwarrior task).

Run it at the start of **every** checkpoint, not just the first: it is local
and cheap, and the note can move under you. When the task is closed (a PR
merged, the issue closed elsewhere), wk moves its note into `archive/` at
once, mid-session or not. Write to the `note` this run printed, never a path
remembered from an earlier checkpoint.

It asks `wk` which task this session belongs to: the task its tmux window was
opened for, else the one this Claude session adopted (`wk adopt` records it,
so this holds outside tmux and in ~/.dotfiles too), else the one whose worktree
this is, else the issue on the branch. That covers work without an issue too.
If this session is about a different piece of work than that (an investigation
worked on from another checkout), say which: `wiki_checkpoint resolve --issue
KEY`, or `--task UUID` for a task without an issue (prefer the uuid: ids shift
as tasks close). An issue filed for the work this session adopted without one
needs no new task: `--issue KEY` gives the session's task the issue, and its
note is renamed to match.

- Exit 2 (no task found) or 3 (vault has no schema): there is nowhere to
  checkpoint. Say so in one line and carry on; don't improvise a location.
- Any other failure: file a friction report (step 5) and carry on.

## 2. Read the rules, once per session

Read `<vault>/CLAUDE.md`. It is the schema: note types, conventions, the
checkpoint workflow, what belongs in the wiki and what doesn't. It wins over
anything written here. On later checkpoints in the same session you don't need
to read it again.

On the first checkpoint also read the task note itself and, if the work touches
a topic the wiki covers, skim `<vault>/index.md` for the pages to keep in mind.

## 3. Write

Only what changed since your last checkpoint in this session:

- **Task note**: keep `## Summary` current (two or three sentences on where the
  work stands), then update `## Plan`, `## Findings`, `## Decisions` (with the
  why, and what was rejected) and `## Links` (PRs, issues). Rewrite and
  reorganise rather than appending a log; the note should read well to someone
  who opens it cold.
- **Today's daily** (`<vault>/dailies/YYYY-MM-DD.md`, only where the vault's
  schema gives the dailies to you): one bullet for this task
  under `## Worked on`, linking the task note, saying what moved. If the bullet
  is already there, refresh it instead of adding another.
- **Hubs, pages, people, and the index: only when warranted.** Something
  durable was learned that outlives this task: how an external system really
  behaves, a customer's setup, a decision about architecture. Then follow the
  schema's ingest workflow: extend the page it belongs on, or write a new page
  under the hub (listed on its `## Pages`) when the schema's split rule says so.
  Most checkpoints don't touch them.
- **Link what you mention.** When the task note names a customer, a system, a
  person or another task, check the indexes (`index.md` for hubs,
  `wiki/Tasks index.md`, `wiki/People index.md`) and link the page if there is one.
  The links are what let a later session find this note from the topic's side.
- **Say what the wiki did for you** under `## Wiki use` in the task note, one
  dated line per page that mattered since your last checkpoint:
  `- 2026-09-24 helped: [[Heroma KIM licence files]] — explained the 403 at once`,
  `- … wrong: [[X]] — says Y, the code does Z (fixed)` or
  `- … missing: no page on Z; had to read the code`. Fix what was wrong on the
  page itself, or add it to [[Open questions]] when you can't settle it. Skip
  the section when you didn't use the wiki; a weekly report
  (`wiki_checkpoint usage`) reads these lines, so honest "didn't help" lines are
  as useful as praise.
- **Don't let a durable finding die in a task note.** If you learned something
  that outlives the task but a page isn't warranted yet (or the right
  page doesn't exist), add one line under `## Wanted` in `index.md` naming the
  subject and pointing at this note. Task notes get archived; the index doesn't.

Other sessions may be writing to the same vault. Re-read a shared file (the
daily, `index.md`, `log.md`) immediately before editing it, and make small
edits. If an edit is refused because the file changed underneath you, re-read
and try once more.

## 4. Commit exactly what you touched

```
wiki_checkpoint commit "<vault>" -- "<file>" "<file>" ... <<'MSG'
checkpoint: <ISSUE-KEY> <what moved, in a few words>

Co-Authored-By: <model name and version> <noreply@anthropic.com>
MSG
```

`<vault>` is the `vault=` path `resolve` printed, or the vault's name
(`bemlo`, `personal`, as the session-start list names them). Where a heredoc
is refused (a worktree-isolated agent's sandbox), write the message to a file
in your scratchpad and pass it with `-F <file>` before the `--` instead.

List every file you edited and nothing else. Never `git add -A`, `git add .`
or `git commit -a` in a vault: other sessions have work in progress there.
"Nothing to commit" is fine.

A commit that carries a task note is refused unless today's daily links that
note or its parent's. That holds on every day of a long session, not just the
first: the daily is the only record of which days a task was worked on. So
the task note and the daily normally go in the same commit. When the commit
records no work done today (a status flip, a typo), add a trailer line before
`Co-Authored-By` instead: `No-Daily: <why>`.

Then, once the commit has gone through:

```
wiki_checkpoint mark
```

`mark` refuses while this session's last commit failed: a refused commit means
nothing was checkpointed. Fix what the commit said (a note that moved: edit the
path it names) and commit again first.

If nothing worth keeping happened since the last checkpoint, skip steps 3 and 4
and just run `wiki_checkpoint mark`.

## 5. When something gets in the way

If the process fights you (the commit lock times out, a file keeps changing
under you, the schema is ambiguous or contradicts itself, the task note can't
be resolved, a reminder fired at a silly moment, a permission prompt blocked a
write), don't work around it silently and don't sink time into it. Report it
and move on. The same goes for friction outside the wiki that cost you time on
the task itself (a tool that misbehaved, a script that ought to exist): file it
with `--scope env`.

```
wiki_checkpoint friction "<vault>" "<short slug>" <<'REPORT'
What I was doing, what happened (exact error text), what I did instead, and
what would have prevented it.
REPORT
```

If `resolve` failed and you have no vault, use the vault the work evidently
belongs to under `~/vaults/`. These reports are how the process gets fixed, so
be specific and candid.
