---
name: lg
description: Let's go — start work on a Linear issue, resolved from the current branch or a supplied ticket arg (e.g. BEMLO-1234). Use when the user wants to begin work on a ticket.
disable-model-invocation: true
---

Get to work on a Linear issue.

## Steps

1. **Determine the Linear ticket ID** by trying these in order:
   - Argument passed to the command (e.g. `/lg BEMLO-1234`)
   - Infer from the current git branch name (e.g. `user/bemlo-1234-...` → `BEMLO-1234`)
   - If neither works, ask the user with AskUserQuestion

2. **Fetch the issue** using `mcp__linear-server__get_issue` and read its
   description, comments, and any linked attachments. Follow links that matter
   (sub-issues, related tickets, design docs).

3. **Familiarize yourself with the issue.** Understand what's being asked, the
   acceptance criteria, and how it maps onto this codebase. Explore the relevant
   code before forming a plan.

4. **Invoke the `grill-me` skill** to stress-test your understanding and the
   plan with me before writing any code.
