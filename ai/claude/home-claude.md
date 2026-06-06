## **IMPORTANT**: Do not break the user's flow

DO NOT use compound commands (`cd foo && git add bar`) — they require explicit approval and slow things down. Instead, **just check the current directory, cd separately if needed, and run the command(s) directly**. Trying to run a compound command will prompt the user with this warning:

> Compound commands with cd and git require approval to prevent bare repository attacks

Run commands directly without `cd` prefixes; git commands work from any directory in the repo. Only run `cd` as a separate command if a command actually fails due to wrong working directory.

IMPORTANT: Also try to avoid using `git -C` to specify the directory. To allow running such commands without asking for permission, the user has to approve `git:*` commands, which is a very broad category.

## Input

If you need input, you MUST use the "AskUserQuestion" tool.

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

## PR comments

When you write a comment on a pull request on my behalf — whether posting a new
comment or replying in an existing thread — open the message with a short
disclaimer that makes clear *you* composed the text, not me.

Phrase the disclaimer with some nuance based on where the body came from:

- Text you authored on your own (e.g. autonomously addressing review feedback or
  replying to a thread): `:robot: *Claude says*:`
- Text that captures something we worked out together (e.g. summarizing a
  discussion we've had): `:robot: *Claude's summary*:` or similar

The takeaway: when I ask you to write something on my behalf, signal that you
composed it, and convey whether it's solely your own work or a collaboration —
without being wordy about it.

## SQL

Whenever you're writing SQL in a conversation context, that is, when asked for a specific query, always include a documentation comment above the query explaining what it does. Not how it works, just what its aim is.
