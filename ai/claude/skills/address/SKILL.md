---
name: address
description: Read comments and full comment threads on the current branch's GitHub pull request, then plan solutions to address the feedback. Use when the user wants to respond to PR review feedback.
---

# Address PR Feedback

Read and address review comments on the current branch's GitHub pull request.

## Steps

### 1. Identify the pull request

Use `gh` to find the PR for the current branch.

### 2. Fetch all comments and threads

Use `gh` to retrieve all review comments, inline comments, and top-level PR comments. Read entire comment threads — threaded replies contain critical context, follow-up instructions, and clarifications.

### 3. Categorize each comment or thread

For each comment or thread, determine whether it is:

- **Actionable**: requests a code change, fix, or improvement. Plan a solution.
- **Informational**: provides context, praise, or acknowledgement. Safe to skip.
- **Ambiguous**: unclear whether action is needed. Ask the user using AskUserQuestion.

When a thread contains multiple messages, consider the full thread to determine the category. A thread that starts informational may become actionable through follow-up replies.

### 4. Plan solutions

For each actionable comment:

1. Identify the file(s) and code referenced
2. Read the relevant code
3. Describe the change needed to address the feedback

Present a summary of all actionable items and proposed solutions to the user before making any changes. Group related comments that can be addressed together.

### 5. Ask before proceeding

After presenting the plan, ask the user whether to proceed with the changes, adjust the plan, or skip specific items.

### 6. Commit the changes

Land review feedback as new, focused commits on the feature branch. Each commit should address one comment or one group of closely related comments, so reviewers can see exactly what changed in response to their feedback.

Do not fold review changes back into the commits being reviewed — no `git commit --amend`, no fixup/squash onto the original work. A reviewer who has already read a commit should not find it silently rewritten under them.

Rebasing and force pushing the branch itself is fine, and is expected when maintaining a stack of PRs. The rule is about where feedback lands, not about the branch being immutable.
