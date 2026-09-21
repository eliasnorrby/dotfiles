## Input

If you need input, you MUST use the "AskUserQuestion" tool.

Every AskUserQuestion call must end with a catch-all question, so I can
comment on what you just said without refusing the other questions:

- question: "Is there anything else you want to add?", header: "Comments"
- options: "No, carry on" (first) and "Yes, see my note". My actual comment
  arrives as the free-text "Other" answer or as a note on the selection.

The tool takes at most 4 questions, so ask at most 3 real ones per call. If
you have more, send them in a follow-up call rather than dropping the
catch-all.

When I do add a comment, respond to it before acting on the other answers —
it may change what they mean.

## Commits

When committing, ensure the message is at most 72 characters in width.

Use conventional commit messages when that pattern is used in the project.

Here's a model commit message:

```
feat(topic): short (50 chars or less) summary

More detailed explanatory text, if necessary.  Wrap it to about 72
characters or so.  In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body.  The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Write your commit message in the imperative: "Fix bug" and not "Fixed bug"
or "Fixes bug."  This convention matches up with commit messages generated
by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here

- Use a hanging indent
```

## Rebasing a stack of PRs

When a branch that others are stacked on gets rewritten — rebased onto master,
amended, or given a new commit — plain `git rebase <parent>` on the children is
wrong. It tries to replay the parent's old commits, which either conflicts or
silently duplicates them.

Capture every parent's tip **before** rewriting anything, then replay only each
child's own commits:

```
git rebase --onto <new parent> <that parent's old tip> <child>
```

Cascade downwards, one branch at a time. Each child's old base is its
**parent's** pre-rewrite tip — not the child's own tip. Getting that wrong
collapses the branch to zero commits.

After each hop, check the commit count against what it was before. If it
changed, stop. Branches already pushed can be restored with
`git branch -f <branch> origin/<branch>`.

## Comments posted under my name (GitHub, Slack)

When you write something that goes out under my name — a PR comment, a reply
in a review thread, a Slack message — open it with an emoji marker on its own
line, then a blank line, then the body. The marker is the whole disclaimer;
don't also say in words that you composed it.

- GitHub: `:robot: :speech_balloon:`
- Linear: `:robot_face: :speech_balloon:`
- Slack: `:claude: :speech_balloon:` (matches what Edvin posts). Slack already
  appends its own "Sent using Claude" footer — don't add another.

Example of the shape:

```
:robot: :speech_balloon:

Rebased onto master and re-ran the backend suite — all green.
```

## SQL

Whenever you're writing SQL in a conversation context, that is, when asked for a specific query, always include a documentation comment above the query explaining what it does. Not how it works, just what its aim is.

## Session titles

When the session's work is centred on a Linear issue — it started with `/lg`,
I handed you a ticket id, or you fetched an issue that is clearly the subject
of the work — name the session after it as soon as you know the issue's title:

```
claude_session_title set "BEMLO-1234 Fix invoice rounding"
```

Format: issue identifier, a space, the issue title verbatim. The title is
applied on my next prompt (a UserPromptSubmit hook picks it up), so run it
once and carry on; don't wait for it to take effect. Skip it when the issue is
only incidental, e.g. you looked one up to answer a question.
