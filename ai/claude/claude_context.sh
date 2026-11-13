#!/usr/bin/env bash

# Which context Claude Code gets in a directory: work, personal, or whatever
# else a tree declares. A tree declares one with a claude-context.json at its
# root, found by walking up from the directory the way .mcp.json is; with none,
# no context applies. The files are machine-local: a ~/claude-context.json is
# the fallback for everything under home. See README.md here for what the
# file may hold.
#
#   claude_context [dir]         the file that applies, and its contents
#   claude_context --path [dir]  just the file's path
#   claude_context --args [dir]  the flags the claude wrapper adds, one per line
#
# CLAUDE_CONTEXT=none turns it off (no file, no flags); CLAUDE_CONTEXT=<file>
# picks a file regardless of the directory.

set -euo pipefail

marker="claude-context.json"
mode=show
case "${1-}" in
  --path | --args)
    mode=${1#--}
    shift
    ;;
  -h | --help)
    sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
esac
dir=${1:-$PWD}

resolve() {
  case "${CLAUDE_CONTEXT-}" in
    none)
      echo "none (CLAUDE_CONTEXT=none)"
      return 1
      ;;
    ?*)
      printf '%s\n' "$CLAUDE_CONTEXT"
      return 0
      ;;
  esac
  local at
  at=$(cd "$dir" && pwd)
  while :; do
    if [ -f "$at/$marker" ]; then
      printf '%s\n' "$at/$marker"
      return 0
    fi
    [ "$at" = / ] && break
    at=$(dirname "$at")
  done
  echo "none (no $marker here or above)"
  return 1
}

if ! file=$(resolve); then
  [ "$mode" = show ] && printf '%s\n' "$file"
  exit 0
fi
if [ ! -f "$file" ]; then
  echo "claude_context: $file does not exist" >&2
  exit 1
fi

case "$mode" in
  path)
    printf '%s\n' "$file"
    ;;
  show)
    printf '%s\n\n' "$file"
    # Header values are usually keys; show their names only.
    jq 'if .mcpServers then .mcpServers |= map_values(
          if .headers then .headers |= map_values("[redacted]") else . end)
        else . end' "$file"
    ;;
  args)
    if ! command -v jq >/dev/null; then
      echo "claude_context: jq is missing, so no context is applied" >&2
      exit 1
    fi
    if ! jq -e . "$file" >/dev/null 2>&1; then
      echo "claude_context: $file is not valid JSON, so no context is applied" >&2
      exit 1
    fi
    # The settings go inline; the servers go by path, so a header holding an
    # API key stays out of the process list. claude ignores the file's other
    # keys there.
    settings=$(jq -c '.settings // empty' "$file")
    [ -n "$settings" ] && printf -- '--settings=%s\n' "$settings"
    if jq -e '.mcpServers' "$file" >/dev/null; then
      printf -- '--mcp-config=%s\n' "$file"
    fi
    ;;
esac
