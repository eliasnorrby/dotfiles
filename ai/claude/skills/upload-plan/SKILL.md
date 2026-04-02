---
name: upload-plan
description: Upload the current plan file as an attachment to a Linear ticket. Use when the user wants to persist a plan to Linear for cross-machine workflows.
---

Upload the current conversation's plan file to a Linear ticket as a markdown attachment.

Linear tickets are identified by a code like `TEAM-1234`.

## Steps

1. **Determine the Linear ticket ID** by trying these in order:
   - Argument passed to the skill (e.g. `/upload-plan TEAM-1234`)
   - Parse the current plan file for a `**Ticket**:` line (e.g. `**Ticket**: TEAM-1234`)
   - Infer from the current git branch name (e.g. `user/team-1234-...` → `TEAM-1234`)
   - If none work, ask the user with AskUserQuestion

2. **Read the current plan file** from the path specified in the plan mode system message. If not in plan mode, check for a recently written plan in `~/.claude/plans/`.

3. **Base64-encode** the plan file content using the Bash tool.

4. **Upload** using `mcp__linear-server__create_attachment`:
   - `issue`: the ticket ID
   - `title`: "Implementation Plan"
   - `filename`: "implementation-plan.md"
   - `contentType`: "text/markdown"
   - `base64Content`: the encoded content

5. **Confirm** to the user: "Uploaded plan to {TICKET_ID}."
