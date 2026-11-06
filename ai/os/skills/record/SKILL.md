---
name: record
description: File a source Elias hands you into his LLM-maintained wiki, on the pages where it belongs, in the vault's own words. The source is a link or a thing he points at — a PR or a comment on one, a Slack thread, a Linear issue, a mail, a meeting, something he just said — and the request is "record this", "document this", "put this in the wiki", "write this up", "spara det här i wikin", or a bare link with "wiki" nearby. Not for the session's own work; that is the wiki-checkpoint skill.
---

Recording is an operation on the wiki, not a piece of work: it gets a
`log.md` entry and a commit, **not a task of its own**. Don't `wk adopt`
for it. If the source belongs to a task that exists (the session's own, or
one the source names by issue key or PR), its note gets the finding too,
through the checkpoint skill; a task is never created so that a recording
has somewhere to go.

## 1. Read the source whole

Fetch it, don't paraphrase it from the request:

- A PR: `gh pr view <n> --repo <o/r> --json title,author,state,mergedAt,body,comments,reviews`.
  A comment link (`#issuecomment-<id>`): `gh api repos/<o/r>/issues/comments/<id>`.
  A review thread: `gh api repos/<o/r>/pulls/<n>/comments`.
- A Slack thread: the Slack tools, the whole thread, and the message the
  permalink points at identified.
- A Linear issue: the Linear tools, with comments.
- Mail, a document, a transcript: as the tools allow, in full.

Read what the source leans on as well: the PRs it cites, the issue it
fixes, the thread it answers. They are part of the story, and often the
wiki already has them. Note who wrote each thing and when.

## 2. Find where it belongs

Pick the vault (`wk config get vaults`; each vault's `CLAUDE.md` says what
belongs in it) and read that `CLAUDE.md` once. Then navigate as the
`recall` skill does: `index.md` in full, the hubs whose summaries touch the
subject, their pages. Grep only for identifiers (`BEMLO-1234`, `#9629`, a
script's name). Most sources continue a thread the wiki already holds, so
the usual result is a section or a few bullets on existing pages, each hub
pointing at it; a new page only when the schema's split rule says so, with
its line on the hub's `## Pages`.

## 3. Verify before you assert

A source says things. Where a claim can be checked cheaply (a PR's state,
what a script does, what a config holds), check it in the repository, on
GitHub or in the tracker, and write what is true, dated. What can't be
checked is written as the author's claim ("Elias, 2026-10-03: …"). Never
write that a PR or issue is open on the source's word alone.

## 4. Write, as the schema's ingest workflow says

- The pages: the finding in the vault's voice, dated and attributed. Quote
  verbatim only where the wording itself matters (the person's own framing,
  a term of art); summarise the rest.
- Each hub the source bears on: its bullet or line updated, `## Pages` and
  `## Sources` kept current, `updated:` bumped. `index.md` only when a hub's
  one-line summary changed.
- What the source raises but the wiki can't yet place: a line under
  `## Wanted` in `index.md`.
- A task note only when step 0 found one; then via the checkpoint skill.
- Not the daily, where the vault's dailies are yours: it records what Elias
  did, and the recording is a wiki operation. The exception is a source
  that belongs to a task worked on that day; then the task's bullet covers it.
  A commit that touches a task note is refused without that bullet; when
  the task wasn't worked on today, add the trailer
  `No-Daily: recorded a source` before `Co-Authored-By` instead.

## 5. Log and commit

Append the entry to `log.md` (`ingest | <source>`: the source by URL or
identifier, the pages touched, the judgement calls, including anything the
source claimed that you found to be otherwise), then commit exactly the
files you touched:

```
wiki_checkpoint commit "<vault>" -- "<file>" ... <<'MSG'
ingest: <what, in a few words>

Co-Authored-By: <model name and version> <noreply@anthropic.com>
MSG
```

## 6. Report

Say where it landed (pages and sections), what you checked and corrected,
what you left out and why, and whether the wiki already had the background
the source continues. A gap in the wiki that made the filing hard (a hub
summary that didn't lead there, a page that said the opposite) is worth a
sentence: it is what the next recording will trip on.
