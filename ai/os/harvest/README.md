# Harvest tooling

The deterministic half of backfilling a vault's wiki from old sources;
sub-agents do the reading. Nothing here names an employer: what to harvest,
and from where, is decided per run. How it was used, and what it taught, is
on the Agentic OS hub in the personal vault.

Transcripts, driven by `wiki_backfill` (linked into the bin by `ai/os`: `list`,
`reduce`, `brief`; it reads the two files below from its own folder):

- `transcript-reduce.jq` — a Claude Code transcript reduced to prompts,
  assistant text and one line per tool call.
- `digest-brief.md` — the brief for a sub-agent digesting one reduced transcript.

Sources at large (PRs, Slack, Notion, mail, notes):

- `harvest-brief.md` — the brief for a sub-agent digesting a bundle into
  candidate pages.
- `pr_list.py REPO USER FROM TO` — PRs a user authored, reviewed or commented
  on, month by month (GitHub search caps at 1,000 results).
- `pr_fetch.py OUTDIR < list.tsv` — one JSON per PR: body, files, comments,
  reviews, review threads.
- `pr_triage.py JSONDIR [REGEX]` — discussion signals per PR (longest human
  comment, total human text, threads, Elias's role), bots filtered.
- `pr_render.py [--focus REGEX] FILE.json…` — compact markdown for a digest
  agent, human discussion only.
- `dailies.py VAULT < timeline.md` — thin dailies from census timeline lines
  `- YYYY-MM-DD — what — Page[; Page]`.

Shape of a run: list → fetch → triage (check keep rates per quarter: a bot the
filter misses makes nearly everything pass) → render into ~300 KB bundles →
one digest agent per bundle → era censuses → one final census for Elias →
page writers after his review.
