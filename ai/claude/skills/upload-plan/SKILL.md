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

2. **Locate the plan file** at the path specified in the plan mode system message. If not in plan mode, check for a recently written plan in `~/.claude/plans/`.

3. **Get the exact byte size** with `wc -c < "$file"`. `prepare_attachment_upload` requires the real size — a mismatch makes the upload fail.

4. **Prepare the upload** with `mcp__linear-server__prepare_attachment_upload`:
   - `issue`: the ticket ID
   - `filename`: "implementation-plan.md"
   - `contentType`: "text/markdown"
   - `size`: the byte count from step 3
   - `title`: "Implementation Plan"

   It returns an `assetUrl` and an `uploadRequest` containing `url` and `headers`.
   **The signed `url` expires in 60 seconds** — do steps 4–6 for one file back to
   back, and never batch prepares.

5. **PUT the raw bytes** to `uploadRequest.url` with Bash/curl (not MCP). Two rules:
   - Send **every** header from `uploadRequest.headers` verbatim, casing included.
     Omitting or altering a signed header returns HTTP 403. In practice these are
     `content-type`, `cache-control`, `x-goog-content-length-range`, and
     `Content-Disposition`.
   - Upload the file as-is — no encoding or transformation.

   The signed URL contains `&` and `%`, so it gets mangled if pasted bare into a
   shell command. Write it to a temp file with a quoted heredoc and pass it as
   `"$(cat "$urlfile")"`:

   ```bash
   curl -sS -X PUT --data-binary @"$file" \
     -H "content-type: text/markdown" \
     -H "cache-control: public, max-age=31536000" \
     -H "x-goog-content-length-range: $size,$size" \
     -H 'Content-Disposition: attachment; filename="implementation-plan.md"' \
     -w '\nHTTP %{http_code}\n' \
     "$(cat "$urlfile")"
   ```

   Confirm the response is `HTTP 200` before continuing.

6. **Finalize** with `mcp__linear-server__create_attachment_from_upload`:
   - `issue`: the ticket ID
   - `assetUrl`: the `assetUrl` from step 4 (the `uploads.linear.app/...` one, *not*
     the `storage.googleapis.com` signed URL)
   - `title`: "Implementation Plan"

7. **Confirm** to the user: "Uploaded plan to {TICKET_ID}."
