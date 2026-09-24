#!/usr/bin/env bash

# Claude status line
# https://code.claude.com/docs/en/statusline
#
# Line 1: the session (model, directory, branch, context, duration).
# Line 2: the work it belongs to (issue, PR) and rate limits,
# printed only when there is something to say.
#
# Pass --debug to log each JSON input to ~/.cache/claude/statusline.log.

# Segments are called by name from join_segments.
# shellcheck disable=SC2329

input=$(cat)

if [[ "$1" == "--debug" ]]; then
  log_file="$HOME/.cache/claude/statusline.log"
  mkdir -p "$(dirname "$log_file")"
  printf '=== %s ===\n%s\n\n' "$(date '+%F %T')" "$(jq . <<<"$input")" >>"$log_file"
fi

RESET=$'\e[0m'
BOLD=$'\e[1m'
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
MAGENTA=$'\e[35m'
CYAN=$'\e[36m'
WHITE=$'\e[37m'
GREY=$'\e[90m'
BLUE=$'\e[94m'

# Nerd Font glyphs, written as escapes: private-use characters do not survive
# every editor and pipe.
ICON_MODEL=$'\uec19'
ICON_DIR=$'\uf07b'
ICON_BRANCH=$'\U000f062c'
ICON_CONTEXT=$'\ue64d'
ICON_CLOCK=$'\uf017'
ICON_ISSUE=$'\uf41b'
ICON_PR=$'\uf407'
ICON_LIMIT=$'\U000f0e7a'

# One jq call; fields are joined with the unit separator, so empty ones
# survive `read` (a tab would collapse them).
IFS=$'\x1f' read -r session_id model effort current_dir lines_added \
  lines_removed duration_ms ctx_pct ctx_size ctx_tokens pr_number pr_url \
  pr_state limit_5h limit_7d repo_owner repo_name < <(
    jq -r '[
      .session_id,
      .model.display_name,
      .effort.level,
      (.workspace.current_dir // .cwd),
      .cost.total_lines_added,
      .cost.total_lines_removed,
      .cost.total_duration_ms,
      .context_window.used_percentage,
      .context_window.context_window_size,
      (.context_window.current_usage
        | if . then .input_tokens + .cache_creation_input_tokens
                    + .cache_read_input_tokens
          else null end),
      .pr.number,
      .pr.url,
      .pr.review_state,
      .rate_limits.five_hour.used_percentage,
      .rate_limits.seven_day.used_percentage,
      .workspace.repo.owner,
      .workspace.repo.name
    ] | map(. // "" | tostring) | join("\u001f")' <<<"$input"
  )

# Keep the latest rate limits where a session can read its own (a long agent
# run checks them to pace itself): one file per session, since sessions on
# other accounts report other limits. Written atomically; only when present.
if [[ -n "$limit_7d" && -n "$session_id" ]]; then
  limits_file="$HOME/.cache/claude/rate-limits/$session_id.json"
  mkdir -p "$(dirname "$limits_file")"
  jq -c --arg at "$(date -Iseconds)" '{at: $at, rate_limits}' <<<"$input" \
    >"$limits_file.tmp" && mv "$limits_file.tmp" "$limits_file"
fi

# ============================================================================
# Helpers
# ============================================================================

# An OSC 8 hyperlink: link URL TEXT
link() {
  if [[ -n "$1" ]]; then
    printf '\e]8;;%s\a%s\e]8;;\a' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}

# Colour for a percentage: green, then yellow from $2, red from $3.
level_colour() {
  local pct=${1%.*}
  if ((pct >= $3)); then
    printf '%s' "$RED"
  elif ((pct >= $2)); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# 1234 -> 1.2k, 340000 -> 340k, 1000000 -> 1M
human_tokens() {
  local n=$1
  if ((n >= 1000000)); then
    printf '%sM' "$(awk "BEGIN { printf \"%.3g\", $n / 1000000 }")"
  elif ((n >= 10000)); then
    printf '%dk' $((n / 1000))
  elif ((n >= 1000)); then
    printf '%sk' "$(awk "BEGIN { printf \"%.1f\", $n / 1000 }")"
  else
    printf '%d' "$n"
  fi
}

format_duration() {
  local s=$(($1 / 1000))
  if ((s >= 3600)); then
    printf '%dh %dm' $((s / 3600)) $((s % 3600 / 60))
  elif ((s >= 60)); then
    printf '%dm' $((s / 60))
  else
    printf '%ds' "$s"
  fi
}

# The wk task this session belongs to, as its issue, PRs and the issue's
# URL. wk resolve is quick but not free, and the status line runs after every
# message, so the answer is cached per session for a little while.
wk_task() {
  command -v wk >/dev/null || return
  local cache_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/claude-statusline"
  local cache="$cache_dir/${session_id:-none}.wk"
  if [[ -f "$cache" ]] && (($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || stat -f %m "$cache") < 15)); then
    cat "$cache"
    return
  fi
  mkdir -p "$cache_dir"
  local resolved issue prs url=""
  resolved=$(wk resolve --json --offline -C "$current_dir" 2>/dev/null)
  IFS=$'\x1f' read -r issue prs < <(
    jq -r 'select(.ok) | [.issue // .task.issue, .task.prs]
      | map(. // "") | join("\u001f")' <<<"$resolved" 2>/dev/null
  )
  if [[ -n "$issue" ]]; then
    local workspace
    workspace=$(wk config get "teams.${issue%%-*}.workspace" 2>/dev/null)
    [[ -n "$workspace" ]] && url="https://linear.app/$workspace/issue/$issue"
  fi
  printf '%s\x1f%s\x1f%s\n' "$issue" "$prs" "$url" | tee "$cache"
}

# ============================================================================
# Segments (each prints a formatted string, or nothing when N/A)
# ============================================================================

segment_model() {
  [[ -n "$model" ]] || return
  printf '%s%s%s %s%s' "$BLUE" "$BOLD" "$ICON_MODEL" "$model" "$RESET"
  [[ -n "$effort" ]] && printf ' %s%s%s' "$GREY" "$effort" "$RESET"
}

segment_directory() {
  [[ -n "$current_dir" ]] || return
  # The repository, not the directory: a worktree or a subdirectory is named
  # after the checkout it belongs to. The common git dir is shared by every
  # worktree; it is <repo>/.git, or <repo>.git for a bare repository.
  local name="${current_dir##*/}" common
  if common=$(git -C "$current_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
    if [[ "${common##*/}" == .git ]]; then
      common="${common%/.git}"
    fi
    name="${common##*/}"
    name="${name%.git}"
  fi
  printf '%s%s %s%s' "$YELLOW" "$ICON_DIR" "$name" "$RESET"
}

segment_branch() {
  local branch
  branch=$(git -C "$current_dir" branch --show-current 2>/dev/null) || return
  [[ -n "$branch" ]] || branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null) || return
  ((${#branch} > 35)) && branch="${branch:0:34}…"
  printf '%s%s %s%s' "$WHITE" "$ICON_BRANCH" "$branch" "$RESET"
  [[ "${lines_added:-0}" != 0 ]] && printf ' %s+%s%s' "$GREEN" "$lines_added" "$RESET"
  [[ "${lines_removed:-0}" != 0 ]] && printf ' %s-%s%s' "$RED" "$lines_removed" "$RESET"
}

segment_context() {
  # Null before the first API response, and again right after /compact.
  [[ -n "$ctx_pct" ]] || return
  local pct=${ctx_pct%.*} width=10 bar="" i
  local filled=$(((pct * width + 50) / 100))
  for ((i = 0; i < width; i++)); do
    ((i < filled)) && bar+="█" || bar+="░"
  done
  local colour
  colour=$(level_colour "$pct" 50 80)
  printf '%s%s %s%s %s%%' "$WHITE" "$ICON_CONTEXT" "$colour" "$bar" "$pct"
  if [[ -n "$ctx_tokens" && -n "$ctx_size" ]]; then
    printf ' %s%s/%s' "$GREY" "$(human_tokens "$ctx_tokens")" "$(human_tokens "$ctx_size")"
  fi
  printf '%s' "$RESET"
}

segment_duration() {
  [[ -n "$duration_ms" ]] || return
  printf '%s%s %s%s' "$GREY" "$ICON_CLOCK" "$(format_duration "$duration_ms")" "$RESET"
}

segment_issue() {
  [[ -n "$wk_issue" ]] || return
  printf '%s%s %s%s' "$MAGENTA" "$ICON_ISSUE" "$(link "$wk_url" "$wk_issue")" "$RESET"
}

segment_pr() {
  # Claude Code's own PR detection first; the task's PRs (kept current by
  # wk sync) cover what it misses, e.g. a PR on another branch.
  if [[ -n "$pr_number" ]]; then
    local colour="$CYAN" mark=""
    case "$pr_state" in
      approved) colour="$GREEN" mark=" ✓" ;;
      changes_requested) colour="$RED" mark=" ✗" ;;
      draft) colour="$GREY" mark=" draft" ;;
    esac
    printf '%s%s %s%s%s' "$colour" "$ICON_PR" "$(link "$pr_url" "#$pr_number")" "$mark" "$RESET"
  elif [[ -n "$wk_prs" ]]; then
    local pr base="" out=""
    [[ -n "$repo_owner" && -n "$repo_name" ]] && base="https://github.com/$repo_owner/$repo_name/pull"
    for pr in ${wk_prs//,/ }; do
      out+="${out:+ }$(link "${base:+$base/${pr#\#}}" "$pr")"
    done
    printf '%s%s %s%s' "$CYAN" "$ICON_PR" "$out" "$RESET"
  fi
}

segment_limits() {
  # Only once they start to matter.
  local out="" pct
  for window in 5h:"$limit_5h" 7d:"$limit_7d"; do
    pct=${window#*:}
    pct=${pct%.*}
    if [[ -z "$pct" ]] || ((pct < 50)); then
      continue
    fi
    out+="${out:+ }$(level_colour "$pct" 50 80)${window%%:*} ${pct}%${RESET}"
  done
  [[ -n "$out" ]] && printf '%s%s %s' "$GREY" "$ICON_LIMIT" "$out"
}

# ============================================================================
# Compose
# ============================================================================

SEPARATOR="${GREY} │ ${RESET}"

join_segments() {
  local fn part out=""
  for fn in "$@"; do
    part=$($fn)
    [[ -n "$part" ]] && out+="${out:+$SEPARATOR}$part"
  done
  printf '%s' "$out"
}

IFS=$'\x1f' read -r wk_issue wk_prs wk_url < <(wk_task)

# segment_branch is left out for now; add it back after segment_directory.
line1=$(join_segments segment_model segment_directory segment_context segment_duration)
line2=$(join_segments segment_issue segment_pr segment_limits)

printf '%s\n' "$line1"
[[ -n "$line2" ]] && printf '%s\n' "$line2"
exit 0
