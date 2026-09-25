---
name: recall
description: Find what Elias (or the team) already knows, wrote, discussed or decided about something, starting from his LLM-maintained wiki before any other source. Use it whenever a request reaches into the past, in any language — "find my notes on X", "I know I wrote about this somewhere", "where did we discuss", "have we decided", "why did we", "what do we know about X", "hitta mina anteckningar", "jag har skrivit om det någonstans" — and before investigating anything with history (a system, a customer, an external API, an incident, a past decision).
---

The wiki under `~/vaults/` is where past work is filed so it can be found
again. It is organised by links, not by words, and it names things its own
way, so the way in is to navigate it, not to grep for the words of the
request. Other sources come after, and whatever they turn up that the wiki
lacked is a gap to report.

## 1. Pick the vault

`wk config get vaults` and the vaults under `~/vaults/`: each one's
`CLAUDE.md` says what belongs in it ("What belongs here"). Work for the
employer is in its vault, everything else in the personal one. When unsure,
look in both.

## 2. Navigate: index, hub, pages

1. Read `<vault>/index.md` in full. It lists every hub with a one-line
   summary, the sub-indexes (tasks, people, loose pages) and `## Wanted`.
2. Pick the hubs whose summaries touch the subject, generously: the thing
   asked about is often a known debt or a decision on a broader hub. Read
   them in full, including `## Pages`.
3. Read the pages those hubs point to that could hold it, and follow their
   links. Check `wiki/pages/Open questions.md` and the task notes in the
   Tasks index when the subject is recent work.

Grep is for what navigation cannot reach: identifiers (`BEMLO-1234`, `#8215`,
a table or function name) and the subject's own nouns, never the phrasing of
the request ("receipt", "kvitto" miss a page that says "status" and "after
the fact"). Read the titles a grep turns up before going anywhere else.

## 3. Only then, wider

If the wiki does not have it, or has only part of it: its `raw/` (legacy
notes, write-ups, jots), then the tracker, Slack, GitHub PR threads and
Claude transcripts (`~/.claude/projects/*/*.jsonl`, the user's own prompts).
Cite what you find by link.

## 4. Report, and say where it came from

Lead with the answer. Then say plainly how it was found:

- **Found in the wiki**: which page, and how many steps from `index.md`.
  If it took a detour (a grep, a wrong hub), say so: a hub summary or a page
  title that would have led there is worth fixing.
- **Had to go wider**: which sources held it, and **a suggestion for
  capturing it** in the wiki: the page it belongs on (or a new page and its
  hub), and what it should say, in a sentence or two. Offer to write it; if
  it is written, follow the vault's ingest workflow.

When the work belongs to a task, add a line to the task note's `## Wiki use`
("helped", "wrong" or "missing"), as the checkpoint skill describes.
