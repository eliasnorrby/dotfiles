# Commit Changes

Create git commits following project conventions.

## Instructions

1. **Review changes**: Run `git status` and `git diff` to understand what has changed
2. **Stage files**: Stage files logically for atomic commits (prefer specific files over `git add .`)
3. **Create commit(s)**: Use conventional commit format with co-author attribution

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

Always include co-author trailer at the end of the commit message. Detect which model you are and use the appropriate format:

| Model             | Co-Author Line                                              |
| ----------------- | ----------------------------------------------------------- |
| Claude Opus 4.5   | `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`   |
| Claude Sonnet 4   | `Co-Authored-By: Claude Sonnet 4 <noreply@anthropic.com>`   |
| Claude Sonnet 3.5 | `Co-Authored-By: Claude Sonnet 3.5 <noreply@anthropic.com>` |
| GPT-4             | `Co-Authored-By: GPT-4 <noreply@openai.com>`                |
| GPT-4o            | `Co-Authored-By: GPT-4o <noreply@openai.com>`               |

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
