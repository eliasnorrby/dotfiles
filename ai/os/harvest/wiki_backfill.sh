#!/usr/bin/env bash

# The backfill side of the wiki: turning old Claude Code transcripts into
# knowledge the vault never captured. Claude does the reading and writing (a
# sub-agent digests each reduced transcript with the brief, the main session
# merges the digests into pages); this script covers the deterministic parts:
#
#   wiki_backfill.sh list [--since DATE] [--min-prompts N] [--project GLOB]
#                                      One line per transcript under
#                                      ~/.claude/projects: first and last
#                                      prompt dates, session id, prompts, size,
#                                      project directory and title. Newest
#                                      first. Sub-agent transcripts are not
#                                      listed; their parent summarises them.
#   wiki_backfill.sh reduce TRANSCRIPT [OUT]
#                                      Reduce a transcript to the user's
#                                      prompts, the assistant's text and one
#                                      line per tool call (no tool output),
#                                      about 3% of the original. Writes OUT, or
#                                      stdout.
#   wiki_backfill.sh brief                Print the path of the digest brief to
#                                      hand a sub-agent along with a reduced
#                                      transcript and an output path.
#
# Lives in the work vault's _meta/harvest/, next to the jq filter and the
# briefs it uses; run it by path (it is not on PATH).

set -uo pipefail

projects_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
assets_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

die() {
  echo "Error: $*" >&2
  exit 1
}

cmd_list() {
  local since="" min_prompts=1 project="*"
  while [ $# -gt 0 ]; do
    case "$1" in
      --since)
        since="$2"
        shift 2
        ;;
      --min-prompts)
        min_prompts="$2"
        shift 2
        ;;
      --project)
        project="$2"
        shift 2
        ;;
      *) die "unknown option: $1" ;;
    esac
  done
  [ -d "$projects_dir" ] || die "no transcripts under $projects_dir"
  list_rows "$project" "$min_prompts" "$since" | sort -r -k2,2 -k1,1
}

# One unsorted TSV row per transcript. Args: PROJECT_GLOB MIN_PROMPTS SINCE
list_rows() {
  local f
  # Paths under projects_dir start with '-', so keep the directory prefix on
  # every path handed to another command.
  while IFS= read -r -d '' f; do
    jq -rs --arg path "$f" --arg size "$(stat -c %s "$f")" \
      --arg min "$2" --arg since "$3" '
      def prompts: map(select(.type == "user" and .isSidechain != true
        and ((.message.content | type) == "string"
          or any(.message.content[]?; .type == "text"))));
      (prompts) as $p
      | ($p | length) as $n
      | select($n >= ($min | tonumber))
      | ($p | map(.timestamp) | sort) as $ts
      | select($since == "" or $ts[-1][0:10] >= $since)
      | (map(select(.type == "custom-title") | .customTitle) | last
         // (map(select(.type == "ai-title") | .aiTitle) | last)
         // "") as $title
      | [$ts[0][0:10], $ts[-1][0:10], ($p[0].sessionId // "")[0:8],
         "\($n)p", "\(($size | tonumber) / 104857.6 | round / 10)M",
         ($path | sub(".*/projects/"; "") | sub("/[^/]*$"; "")), $title]
      | @tsv' "$f" 2>/dev/null
  done < <(find "$projects_dir" -mindepth 2 -maxdepth 2 -path "$projects_dir/$1/*.jsonl" -print0)
}

cmd_reduce() {
  local transcript="${1:-}" out="${2:-}"
  [ -n "$transcript" ] && [ -f "$transcript" ] || die "usage: wiki_backfill.sh reduce TRANSCRIPT [OUT]"
  if [ -n "$out" ]; then
    jq -r -f "$assets_dir/transcript-reduce.jq" "$transcript" >"$out" || die "reduce failed"
    echo "$out: $(wc -c <"$out") bytes from $(wc -c <"$transcript")"
  else
    jq -r -f "$assets_dir/transcript-reduce.jq" "$transcript"
  fi
}

cmd_brief() {
  [ -f "$assets_dir/digest-brief.md" ] || die "brief missing from $assets_dir"
  echo "$assets_dir/digest-brief.md"
}

[ $# -ge 1 ] || die "usage: wiki_backfill.sh list|reduce|brief ..."

sub="$1"
shift
case "$sub" in
  list) cmd_list "$@" ;;
  reduce) cmd_reduce "$@" ;;
  brief) cmd_brief "$@" ;;
  *) die "unknown subcommand: $sub" ;;
esac
