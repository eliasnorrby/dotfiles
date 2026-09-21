---
name: wiki-checkpoint
description: Record where the current work stands in the user's LLM-maintained wiki (task note, today's daily, and topic pages when something durable was learned). Invoke it yourself, without being asked, when a requirement or design decision is settled, an approach is abandoned, an investigation reaches a conclusion, a PR is opened or merged, before ending a work session, or when a hook reminds you to. Also when the user says "checkpoint", "log this" or "update the wiki".
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

It reads the issue from the branch. If this session is about a different issue
than the branch says (an investigation worked on from another checkout, a
sub-issue handled in its parent's thread), say which:
`wiki_checkpoint resolve --issue KEY`.

- Exit 2 (no issue on the branch) or 3 (vault has no schema): there is nowhere
  to checkpoint. Say so in one line and carry on; don't improvise a location.
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
- **Today's daily** (`<vault>/dailies/YYYY-MM-DD.md`): one bullet for this task
  under `## Worked on`, linking the task note, saying what moved. If the bullet
  is already there, refresh it instead of adding another.
- **Topic and people pages, and the index: only when warranted.** Something
  durable was learned that outlives this task: how an external system really
  behaves, a customer's setup, a decision about architecture. Then follow the
  schema's ingest workflow for those pages. Most checkpoints don't touch them.

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

List every file you edited and nothing else. Never `git add -A`, `git add .`
or `git commit -a` in a vault: other sessions have work in progress there.
"Nothing to commit" is fine. Then:

```
wiki_checkpoint mark
```

If nothing worth keeping happened since the last checkpoint, skip steps 3 and 4
and just run `wiki_checkpoint mark`.

## 5. When something gets in the way

If the process fights you (the commit lock times out, a file keeps changing
under you, the schema is ambiguous or contradicts itself, the task note can't
be resolved, a reminder fired at a silly moment, a permission prompt blocked a
write), don't work around it silently and don't sink time into it. Report it
and move on:

```
wiki_checkpoint friction "<vault>" "<short slug>" <<'REPORT'
What I was doing, what happened (exact error text), what I did instead, and
what would have prevented it.
REPORT
```

If `resolve` failed and you have no vault, use the vault the work evidently
belongs to under `~/vaults/`. These reports are how the process gets fixed, so
be specific and candid.
