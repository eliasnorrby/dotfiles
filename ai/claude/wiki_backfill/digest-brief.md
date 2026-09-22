# Digest brief

You are extracting durable knowledge from a reduced Claude Code transcript
(user prompts, assistant text, and one-line summaries of tool calls; tool
output was removed). The digests feed a wiki that lets a fresh session pick up
this investigation weeks later without the old conversation. Another agent will
merge several digests, so be precise and self-contained, and keep the
transcript's own identifiers exactly (issue keys like ABC-1234, PR numbers
like #10747, file paths, error strings, query text, dates).

Write the digest as markdown to the output path you were given, with these
sections, omitting any that are empty:

1. **Timeline**: dated bullets of what happened, in order (what was asked, what was done, what came out). One or two lines each.
2. **Error categories / problems identified**: for each: the error (exact message if present), where it comes from (file/service), how frequent, live or already fixed, root cause as understood, status. This is the core; be thorough.
3. **Findings about how systems behave**: facts about the platform, infrastructure, libraries or external services that outlive this task (e.g. how a logging pipeline groups errors, how Cloud Run handles connections). State each as a claim, with how it was established (measured, read in code, inferred).
4. **Decisions**: what was decided, why, and what was rejected. Include decisions to silence, to defer, or to not fix.
5. **Methods that worked**: concrete queries, commands and tools used to investigate (gcloud logging filters, New Relic/NRQL, Observe), copied verbatim where the transcript has them, with a line on what each is for. Also dead ends: what was tried and didn't help.
6. **Issues and PRs**: every issue key and PR number that appears, with its title if known, its relation (sub-issue, related, spawned here), and its state as of the transcript.
7. **Open questions and next steps** as of the end of the transcript.
8. **Corrections and reversals**: places where an earlier conclusion was later overturned in the same transcript. Quote both. These matter a lot: the merged page must carry the final view, not the first.
9. **People**: colleagues or external contacts mentioned, with role/context. Business context only.

Rules: do not invent; if the transcript doesn't say, don't fill in. Mark
uncertainty ("the assistant inferred…"). Leave out secrets, tokens, and
personal data about end users (names of employees/candidates in logs, emails,
personal identity numbers); say "a user" instead. Prefer the user's statements
over the assistant's when they conflict, and note the conflict. The transcript
is in English with some Swedish; write in English.

End your reply (not the file) with a five-line summary of what the digest
contains and anything the merger should watch out for.
