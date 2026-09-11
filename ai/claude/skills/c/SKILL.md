# Commit Changes

Create git commits following project conventions.

## Instructions

1. **Review changes**: Run `git status` and `git diff` to understand what has changed
2. **Stage files**: Stage files logically for atomic commits (prefer specific files over `git add .`)
3. **Create commit(s)**: Use conventional commit format with co-author attribution

## Scope: only commit work from this conversation

Commit ONLY changes made as part of the current conversation. Other modified
files in the working tree belong to other sessions or in-progress work — do
not stage them, do not commit them, do not "clean up" by including them.

- Match `git status` output against what this conversation actually touched;
  stage only those files.
- If a file mixes this conversation's changes with unrelated ones, stage
  hunks selectively with `git add -p` (or `git apply --cached`).
- If it is unclear whether a change belongs to this conversation, ask via
  AskUserQuestion instead of including it.

## Atomic Commits

Prefer multiple small, focused commits over one large commit:

- Each commit should represent one logical change
- If changes span multiple concerns, split into separate commits
- Keep commits reviewable and revertable

## Commit Message Format

Use conventional commits: `type(scope): description`

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring (no behavior change)
- `chore` - Maintenance tasks, dependencies
- `docs` - Documentation
- `test` - Tests
- `perf` - Performance improvements

**Rules:**

- Subject line max 50 characters (72 absolute max)
- Use lowercase for type and scope
- Use imperative mood: "add feature" not "added feature"
- Wrap body at 72 characters

## Co-Author Attribution

Always include a co-author trailer at the end of the commit message, naming
the model you actually are — including its version — and its vendor's noreply
address:

```
Co-Authored-By: <model name and version> <noreply@<vendor>>
```

These are examples of the format, not a list to pick from:

```
Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Co-Authored-By: Claude Sonnet 4 <noreply@anthropic.com>
Co-Authored-By: GPT-4o <noreply@openai.com>
```

If your model is not shown, follow the pattern rather than claiming to be one
of the models above.

## Commit Command Template

```bash
git add <specific-files>
git commit -m "$(cat <<'EOF'
type(scope): short description

Optional longer description wrapped at 72 characters explaining
the why behind the change.

Co-Authored-By: <model> <email>
EOF
)"
```

$ARGUMENTS
