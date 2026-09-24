# Wiki schema, shared core

An Obsidian vault that imports this file is an LLM-maintained wiki (after
Karpathy's [llm-wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)).
Elias curates sources and asks questions; you do the writing, filing and
cross-referencing. He browses the result in Obsidian. This file is the part of
the schema every vault shares; the vault's own `CLAUDE.md` says what differs:
which folders it has beyond the core, what belongs in it, who writes dailies,
how tasks are keyed. Follow both, and propose changes when they stop fitting.

## Layout and ownership

```
CLAUDE.md          the vault's schema; imports this file
index.md           the entry point: hubs by kind, the other indexes, Wanted
log.md             append-only record of changes to the wiki
inbox/             what has not been processed yet; always empties out
                   Elias's jots (one timestamped file each), your digests,
                   and archive/ for notes he has queued for archiving
dailies/           one note per day; the vault says who writes them
wiki/              yours
  tasks/           one note per task (unless the vault keeps them elsewhere)
  topics/          hubs: a system, concept, customer or investigation
  pages/           everything else: one page per thing worth a page, flat
  people/          one page per person worth linking to
raw/               sources that stay. Read, never edit, move or delete.
  jots/            Elias's jots once they have been ingested
private/           Elias's own notes that are never ingested. Don't read it.
_meta/
  attachments/     images and files embedded from notes
  templates/       Obsidian and obsidian.nvim templates
  friction/        reports from sessions about what got in their way
  usage/           weekly reports on how sessions use the wiki (script-written)
```

**`inbox/` versus `raw/`**: things leave the inbox; things stay in raw. A jot
sits in `inbox/` until a session has ingested it, then moves to `raw/jots/`
(`git mv`, same file name) and is cited from there. A digest is deleted once
merged; git history keeps it. A note in `inbox/archive/` is one Elias has
queued for archiving: mark its subject as past on every page that links to it,
then file it where the vault says archived material goes.

**`private/` is off limits**: never read, write, lint or cite it. It holds
notes that are Elias's alone. A note that must never be ingested does not
belong in `raw/`, whose whole purpose is to be ingested; it belongs here.

The rule that makes this safe: **you write only to the wiki layer**: `wiki/`,
`dailies/` where the vault gives them to you, `_meta/friction/`, `index.md`,
`log.md`, the vault's `CLAUDE.md`, and your own digests in `inbox/`; a vault
may open a few more paths in `_meta/claude-writable`. Everything else in the
vault is Elias's: his jots and notes, `raw/`, `private/`, `_meta/attachments/`
and `_meta/templates/`, the Obsidian configuration. Conversation transcripts,
PRs and issues are also raw sources; they live outside the vault and are
linked, not copied. A `PreToolUse` hook (`wiki_checkpoint hook pre-tool-use`)
enforces the list for the file tools and refuses `private/` entirely; it does
not watch Bash, so a move Elias asks for still goes through `git mv`.

## Note types

All wiki pages and dailies have frontmatter with at least `type` and `created`
(`YYYY-MM-DD`). Add `updated` whenever you change a page materially.

**Task** — `<ISSUE-KEY> <Title>.md` in the task folder, or `YYYY-MM-DD
<title>.md` without an issue. The unit of working memory: everything about one
piece of work, across however many days and sessions it takes.

```yaml
type: task
task: <taskwarrior uuid>     # the durable key; may be absent for backfilled work
issue: ABC-1234              # optional
pr: [10511, 10514]           # optional
project: <taskwarrior project>
created: 2026-09-21
status: active | done | dropped
closed: 2026-09-30           # set when the task closes
```

Backfilled notes for work that was already closed (no taskwarrior task, so
no `task:` key) are created directly in the task folder's `archive/` with
`status: done`.

Closing is handled outside the wiki: when the taskwarrior task is completed or
deleted, a hook moves the note to `archive/` and sets `status` and `closed`;
reopening moves it back. Don't move notes in or out of `archive/` yourself.
Wikilinks survive the move; do move the note's line in `wiki/Tasks index.md`
next time you touch it.

Sections: `## Summary` (two or three sentences, kept current), `## Plan`,
`## Findings`, `## Decisions` (each with the why and what was rejected),
`## Links`, and `## Wiki use` when the wiki mattered to the work: dated lines
saying which pages helped, which were wrong and what was missing (the
checkpoint skill has the format; `wiki_checkpoint usage` reports on them).
Notes created by `wk` start with only Plan and Findings; add the rest on first
ingest.

**Page** — `wiki/pages/<Title>.md`. The bulk of the wiki: one page per thing
worth a page, free in form. "Dates in Prisma", "How BST came to be", "The
Cloud Run domain mappings", a comparison, a how-to, a piece of history. No
prescribed sections; open with what it is about, end with `## Sources`.
Titles are natural and unique across the vault (Obsidian links by basename):
check for a clash before choosing one, and qualify only when there is one.
A page usually belongs to a hub (`up:`), but it need not: a page can be a dot
waiting for the web to reach it. What it may never be is unreachable: when it
is written it gets a line on its hub's `## Pages`, or, with no hub, on
`wiki/Loose pages.md`.

```yaml
type: page
up: "[[BST (Bemlo Standard Time)]]"   # its hub, when it has one
created: 2026-09-21
updated: 2026-09-21
```

**Topic** — `wiki/topics/<Name>.md`. The **hub** for a system, concept,
customer or recurring theme: the landing page a reader or a session starts
from. It carries a summary, the current state in a few paragraphs, and a
`## Pages` section listing the pages that go deeper, one line each. Written
as a standing reference, not a narrative: reorganise as understanding grows.
Cite where claims come from (task note, raw file, PR, repo path). When a new
source contradicts the page, update it and note what changed rather than
appending a conflicting paragraph.

```yaml
type: topic
kind: system | concept | customer | investigation | other
created: 2026-09-21
updated: 2026-09-21
```

**When a section becomes a page** (the split rule): when it has a name a
second page would link to; when a second page does link to it; or when it
passes about 500 words. A hub past about 1,000 words is overdue for
splitting. The reverse holds too: a page under about 100 words with no
inbound link but its hub folds back into the hub. Split by moving the text,
leaving a one-line pointer in the hub's `## Pages`, and updating every link.

An **investigation** (`kind: investigation`) is a topic for something Elias
returns to over weeks, across several issues and sessions: a recurring class of
incident, a long hunt. It is the page a fresh session is handed when he
mentions the subject, so it leads with the current understanding and keeps, in
this order: `## Current understanding` (with a table of causes, state and
owner where that fits), `## Incident timeline`, `## Ruled out, and conclusions
that were reversed`, `## What to try next`. The reversals matter as much as the
findings: they stop the next session from re-walking the same wrong path. Task
notes hold the detail of each issue, pages hold the detail of each aspect;
the investigation hub holds the whole.

**Person** — `wiki/people/<Name>.md`, so that tasks, topics and meetings can
link to them. Full name when known, otherwise first name plus affiliation:
`Niklas (CGI)`. Keep it to role, organisation, what they are the right person
to ask about, and where they appear. Say so when an affiliation is a guess.
Never create pages for people who are merely subjects of the data, and keep
private details out.

```yaml
type: person
org: CGI
role: Heroma domain expert
created: 2026-09-21
```

**Daily** — `dailies/YYYY-MM-DD.md`, shaped like `_meta/templates/daily.md`.
A record of what Elias did that day, for retracing his steps later.
`## Worked on`: one bullet per task touched, linking the task note, with a
line on what moved. `## Jots`: that day's jots, embedded by full path
(`![[raw/jots/2026-09-22 1451]]`) once they have moved there. Keep it thin;
detail goes in task and topic notes. A vault whose dailies are Elias's own
treats them as sources, and you write none.

## Conventions

- **Language.** English. Translate and summarise Swedish material; quote
  verbatim only where the wording itself matters (a customer's phrasing, a
  term of art, a field or UI label). Elias's own notes are never translated or
  "improved".
- **Links.** Use `[[wikilinks]]` liberally — the graph is the point. Every task
  note links the topics it touches; topics link back to the tasks that shaped
  them. A page with no inbound links is a bug. Mentioning a concept that
  deserves a page and has none: create a stub or list it under "Wanted" in
  `index.md`. Never wrap a wikilink across lines.
- **One H1 per note.** The first heading is `# <Title>`, matching the file
  name; everything below starts at `##`. Tools treat an H1 as the document's
  title, and a second one makes links to the note ambiguous. No slashes or
  colons in titles: they break the file name. Applies to what you write;
  notes under `raw/` are whatever they are.
- **Sources.** Link back to raw sources; provenance is what makes a claim
  checkable. Always a wikilink with the full vault path and an alias, never a
  path in backticks: `[[raw/legacy/dailies/2026-04-07|daily 2026-04-07]]`. Full
  paths because basenames collide. Every topic and task page ends with
  `## Sources`, one bullet per source, with a few words on what it contributed
  where the name doesn't say. Add an inline link as well when a claim is
  surprising, contested or contradicts another source. Sources outside the
  vault (a PR, an issue, a mail thread, a transcript) are cited by URL or by
  identifier and date. A Claude Code session is cited by the first eight
  characters of its id, its worktree and its dates; Claude's auto-memory by
  project and note name. No summary page per source.
- **No machine-local paths.** The vault is read on several devices, so never
  point at `~/...` or `/home/...`. Refer to things outside the vault by
  repository and repo-relative path, or by URL. Paths into the vault itself
  are fine.
- **Identifiers.** Write issue keys (`ABC-1234`), PR numbers (`#10511`) and
  repo paths (`apps/backend/src/cors.ts`) exactly, so they stay greppable.
- **External links.** In `## Links` and `## Sources`, every issue, PR, Slack
  thread, document and page outside the vault is a markdown link whose text
  is the exact identifier, so Elias can follow it and grep still finds it:
  `- [#10939](https://github.com/org/repo/pull/10939) — draft PR, four
  commits`. Inline in prose the bare identifier is fine. Slack threads are
  cited by permalink. The vault's `CLAUDE.md` gives the URL shapes.
- **No secrets.** No credentials, tokens or personal data about third parties,
  even if a source contains them.
- **Currency.** A page says what is true now. When something changes, find
  and edit every page that says otherwise; never add a reading rule ("read
  *stage* in older notes as *test*") for the reader to carry around. Git and
  `log.md` keep the history, and where the past matters it is stated as a
  dated fact ("until September 2026 changes went to stage first"), in a
  timeline section or a sentence, not left standing as the present. Working
  documents (reports, digests, plans that have been carried out) are deleted
  once their content is in the standing pages. Lint proposes forgetting: a
  page nothing links to and nothing has touched for months is a candidate for
  deletion, and its useful lines for merging elsewhere.

## Workflows

**Ingest** — turning a source into wiki content. The source is usually the
current conversation; it can also be a jot, files in `raw/`, a PR, an issue or
a transcript.

1. Read `index.md` to see what exists.
2. Update or create the task note, if the source belongs to a task.
3. Update every page the source bears on, hubs and pages alike; create pages
   for what has none, and split where the split rule says so. One source
   commonly touches several pages. A new page links to its hub and the hub
   lists it.
4. Update the indexes for what was added, renamed or substantially changed:
   a hub's line in `index.md`, a task's in `wiki/Tasks index.md`, a person's
   in `wiki/People index.md`, a hubless page's in `wiki/Loose pages.md`.
5. Add today's daily entry if this was work done today and the dailies are
   yours.
6. Append to `log.md`.
7. If the source was a jot, `git mv` it from `inbox/` to `raw/jots/` and embed
   it in its day's daily; if it was a digest, delete it.
8. Commit (see below).

The vault says whether ingest is supervised (you present the takeaways and the
pages you plan to touch before writing) or unsupervised (verify against the
repo, the tracker or GitHub, write, commit, and list judgement calls in the
log entry). Two subjects are always supervised: one the wiki has never
covered, and raw notes Elias wrote by hand recently.

**Checkpoint**: the light, frequent form of ingest, run by a working session
on its own initiative (the `wiki-checkpoint` skill; hooks remind it). The
source is the session's own context. Update the task note and, where the
dailies are yours, the task's bullet in today's daily. Touch hubs, pages,
people and the index only when something durable was learned that outlives
the task; then steps 3 and 4 of ingest apply. A checkpoint does not write to
`log.md`: the task note and the git history already record it, and the log is
for operations on the wiki as a whole. Commit as described under Git.

**Query** — read `index.md` first, then the hubs and indexes it points to,
then their pages; go to raw
sources only when the wiki falls short, and fix the wiki when it does. If an
answer took real synthesis, offer to file it as a page.

**Lint** — on request. Look for contradictions between pages, claims newer
sources have superseded, orphans (a page with no inbound links is a finding
to fix by linking, not a state to leave), concepts lacking a page, missing
cross-references (never into `private/`), pages the split rule says to split
or fold, pages that can't be reached from `index.md` by following links,
pages with more or fewer than one
H1, stale `status: active` tasks, index entries that no longer match their
page, and files under `raw/` that no wiki page links to (not yet ingested, or
deliberately skipped). Read the latest usage report in `_meta/usage/`
(written weekly by `wiki_checkpoint usage --write`; run it by hand for a fresh
one): pages no session reads are candidates for better links or for
forgetting, and "wrong" or "missing" lines in task notes are fixes to make.
Read the open reports in `_meta/friction/`: group them,
propose a fix for each pattern (to the schema, the skill or the tooling), and
set `status: resolved` on the ones dealt with. Report first, then fix what
Elias agrees to.

## index.md and log.md

The indexes disclose the wiki progressively, so that the first thing a
session reads stays short. `index.md` is the entry point: `## Indexes`
(links to the three below), `## Topics` (every hub, sub-grouped by kind, one
line each: `- [[Hub]] — one-line summary`) and `## Wanted`, plus whatever
sections the vault adds. Pages are listed on their hub's `## Pages`, not here.
Three more indexes live in `wiki/`, each `type: index` with the same one-line
format: `Tasks index.md` (`## Active`, `## Closed`), `People index.md`, and
`Loose pages.md` for pages without a hub. The invariant: every page can be
reached from `index.md` by following links; lint checks it. Keep summaries
specific and to one line; a summary that needs a paragraph is a page that
needs splitting.

`log.md`: append-only, newest last, one entry per operation:

```
## [2026-09-21] ingest | ABC-1234 e2e performance
Source: conversation. Touched: [[ABC-1234 ...]], [[E2E test suite]] (new).
```

Operations: `ingest`, `lint`, `restructure`, `schema`. The log is about the
wiki; what Elias did belongs in the daily.

## Digests

Long sources (Claude Code transcripts, big clusters of notes) are read by
sub-agents, which write a structured digest each; the main session then reads
only the digests, plans pages, and writes. A digest waits in `inbox/` as
`digest <source>.md` with frontmatter `type: digest` and `status: pending`
(the `type` line is what lets the hook tell your digests from Elias's jots).
Digests are a backfill tool, for sessions the capture loop never saw. A
session that checkpoints itself needs no digest afterwards. If digests keep
appearing once backfill is done, the capture loop is not working; say so.
They are working material: not wiki pages, not in the index, not to be linked
from wiki pages (cite the underlying source instead). When you merge one, say
in `log.md` which pages it fed and delete it. Verify what a digest says
against the tracker, GitHub or the repo where that is cheap: transcripts have
lost their tool output, so states and titles are often missing. In particular,
**never write that a PR or issue is open on a transcript's word**: a session
ends before its PR merges. `git log origin/master --grep='#<number>'` settles
it in a second.

## Friction reports

`_meta/friction/` is where a session says what got in its way while
maintaining the wiki: a commit lock that timed out, a file that kept changing
underneath it, a rule here that is ambiguous or contradicts another, a task
note that couldn't be resolved, a reminder at a silly moment. One file per
report, created with `wiki_checkpoint friction "<vault>" "<slug>"` (body on
stdin): what you were doing, what happened with the exact error, what you did
instead, what would have prevented it. Be candid; this is how the process gets
fixed. Reports are exempt from the index and from linking rules. Don't edit
other sessions' reports, except to set `status` during lint.

## Git

The vault is a git repo as a safety net: every change by an agent can be
reviewed and undone. It lives on this machine only; Obsidian Sync distributes
the files and does not carry `.git`.

Several sessions write here at the same time, so **never sweep the working
tree**: no `git add -A`, `git add .` or `git commit -a`. Commit exactly the
files you edited, through

```
wiki_checkpoint commit "<vault>" -- "<file>" ... <<'MSG'
<subject>

Co-Authored-By: <model name and version> <noreply@anthropic.com>
MSG
```

which serialises commits across sessions and refuses to commit the whole tree.
A shared file (`index.md`, `log.md`, a daily) is committed whole, so your
commit may carry another session's lines from that file, and "nothing to
commit" may mean someone else's commit carried yours. Both are fine.

Subjects: `checkpoint: <ISSUE-KEY> <what moved>` for checkpoints; for
everything else mirror the log entry (`ingest: …`, `lint: …`, `schema: …`,
`restructure: …`). One commit per operation. Never rewrite history. Elias's
own files (new jots in `inbox/`, `raw/`, his notes, attachments) and the
moves made by hooks are committed by a timer (`wiki_checkpoint sweep`, as
`auto: sweep <vault>`) once they have sat untouched for five minutes; leave
them alone. The one exception is a jot you ingest: its move to `raw/jots/`
goes in the ingest commit. Every commit is pushed to the vault's `backup`
remote by the same tooling.
