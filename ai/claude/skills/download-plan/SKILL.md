---
name: download-plan
description: Download an implementation plan from a Linear ticket attachment into the current plan file. Use when picking up work from another machine or conversation.
---

Download an implementation plan from a Linear ticket and write it to the current plan file.

Linear tickets are identified by a code like `TEAM-1234`.

## Steps

1. **Determine the Linear ticket ID** by trying these in order:
   - Argument passed to the skill (e.g. `/download-plan TEAM-1234`)
   - Parse the current plan file for a `**Ticket**:` line (e.g. `**Ticket**: TEAM-1234`)
   - Infer from the current git branch name (e.g. `user/team-1234-...` → `TEAM-1234`)
   - If none work, ask the user with AskUserQuestion

2. **Fetch the issue** using `mcp__linear-server__get_issue` to list its attachments.

3. **Find the attachment** with title "Implementation Plan". If not found, inform the user that no plan attachment exists on the ticket.

4. **Download the attachment** using `mcp__linear-server__get_attachment` with the attachment ID. This returns the markdown content directly.

5. **Write the content** to the current plan file (from the plan mode system message). If not in plan mode, write to `~/.claude/plans/` using the current plan filename.

6. **Confirm** to the user: "Downloaded plan from {TICKET_ID}" and display the plan content.
