# Harvest brief

You are reading one bundle of sources (PRs with their review threads, Slack
messages, write-ups, mail) and proposing what the wiki should gain from it.
The wiki is a set of small pages under hubs: a topic page is the landing page
for a subject, and pages go deeper, one page per thing worth a page ("Dates in
Prisma", "How BST came to be", "The Cloud Run domain mappings"). Another agent
merges the proposals of several bundles, so be precise and self-contained, and
keep identifiers exactly (issue keys like ABC-1234, PR numbers like #10747,
file paths, error strings, dates).

**What the wiki wants**: what the repository does not already say. Problems
and how they showed up, bugs and the workarounds that grew around them,
decisions with the why and what was rejected, dead ends, stances people took,
recurring patterns, who was involved, and when things happened. **Not**: how
the code works today (the repo says that), and not a list of every PR. A PR
that only did what its title says deserves at most a line in the timeline.

**Don't presume the themes.** You were given the subject that selected this
bundle, but look for what else is in it: a pattern that crosses several PRs,
a stance someone keeps repeating, a problem nobody named. Those are often
worth more than the obvious.

You get `index.md` and the pages the bundle obviously touches. Read them
first, so you can say what is already known and what is new, and where a
source contradicts the wiki.

Write the digest as markdown to the output path you were given, with this
frontmatter and these sections, omitting any that are empty:

```yaml
type: digest
status: pending
source: <what the bundle is, e.g. "BST PRs 2026-Q1 (34 PRs)">
created: <today>
```

1. **Already in the wiki**: two to five lines on what the existing pages
   already cover, so the merger can skip it.
2. **Candidate pages**: the core. For each:
   - `### <Proposed title>`: natural, specific, unique-sounding; the title
     someone would link to. Say `(existing: [[Page]])` if it extends a page
     that exists, or `(new)`.
   - **Hub**: the topic it belongs under, existing or proposed, or `loose`.
   - **What it's about**: one line, as the index would say it.
   - **Material**: the findings, as dense bullets with their sources inline
     (`#9889`, `ABC-1234`, "Slack #channel 2026-03-04"). Quote verbatim
     where the wording matters (a decision, a stance, a customer's phrasing).
   - **Contradicts**: anything here that disagrees with the wiki, quoted on
     both sides.
   Prefer several focused candidates over one big one. A candidate can be a
   piece of history, a bug and its workarounds, a comparison, a gotcha, a
   decision.
3. **Timeline**: dated one-liners, for the hub's history and for dailies.
   Mark the ones where Elias (`eliasnorrby`) authored or reviewed.
4. **Themes outside the subject**: things in the bundle that belong to other
   subjects, with where they'd go. One or two lines each.
5. **Corrections and reversals**: conclusions that were later overturned,
   within the bundle or against the wiki. Quote both.
6. **People**: colleagues and external contacts, with role or context as
   seen here. Business context only.

Rules: do not invent; if the sources don't say, don't fill in, and mark
inference as inference. Treat agent-generated text (PR bodies written by
Claude, planning documents) as a record of what was proposed, not as fact,
and say which it is. Leave out secrets and personal data about end users
(employees, candidates in data, emails, personal identity numbers). Write in
English; the sources are partly Swedish.

End your reply (not the file) with a five-line summary: how many candidates,
the most valuable ones, and anything the merger should watch out for.
