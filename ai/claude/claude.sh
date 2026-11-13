#!/usr/bin/env bash

# Linked into ~/.local/bin ahead of the real claude, so every launcher (wk,
# tmux, nvim, focus, the wiki drain) goes through it. It adds the flags of the
# context that applies to the working directory (see claude_context and
# README.md here), then hands over to the real claude, the next one on PATH.
#
# Subcommands (claude mcp, claude auth, ...) reject --settings and pass through
# untouched. When anything here fails, claude still starts, without a context.

set -uo pipefail

self=$(readlink -f "$0")
real=
IFS=: read -ra path_dirs <<<"$PATH"
for dir in "${path_dirs[@]}"; do
  candidate="$dir/claude"
  [ -x "$candidate" ] || continue
  [ "$(readlink -f "$candidate")" = "$self" ] && continue
  real=$candidate
  break
done
if [ -z "$real" ]; then
  echo "claude: no claude on PATH besides this wrapper ($self)" >&2
  exit 127
fi

case "${1-}" in
  agents | attach | auth | auto-mode | doctor | gateway | import | install | \
    logs | mcp | plugin | plugins | purge | respawn | rm | setup-token | stop | \
    kill | ultrareview | update | upgrade)
    exec "$real" "$@"
    ;;
esac

flags=()
while IFS= read -r flag; do
  flags+=("$flag")
done < <("$(dirname "$self")/claude_context.sh" --args)

# The odd expansion keeps bash 3.2 (macOS) from calling an empty array unbound.
exec "$real" ${flags[@]+"${flags[@]}"} "$@"
