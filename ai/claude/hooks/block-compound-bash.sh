#!/bin/bash
# PreToolUse hook: block compound Bash commands and git -C.
# Exit codes: 0 = allow, 2 = block

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If parsing failed, allow
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Block git -C
if echo "$COMMAND" | grep -qE '^\s*git\s+-C\b'; then
  echo "BLOCKED: Do not use 'git -C'. Run git commands directly from the working directory." >&2
  exit 2
fi

# Block compound commands (&&, ;)
if echo "$COMMAND" | grep -qE '&&|;'; then
  # Special case: cd ... && ...
  if echo "$COMMAND" | grep -qE '^\s*cd\s+'; then
    echo "BLOCKED: Do not use 'cd ... && ...'. Run commands directly from the working directory." >&2
    exit 2
  fi

  echo "BLOCKED: Compound command detected (contains && or ;). Run each command as a separate Bash tool call." >&2
  exit 2
fi

exit 0
