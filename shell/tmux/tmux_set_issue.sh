#!/usr/bin/env bash
# Annotate the current tmux window from an issue/PR reference on the clipboard.
#
# Detects the source from the clipboard contents and sets the window name
# (@issue) plus the @desc option used by the pane border and window switcher:
#   - Linear issue id or URL (e.g. BEMLO-1234) -> Linear GraphQL API
#   - GitHub PR/issue URL or #num (e.g. #1234) -> gh, repo inferred from cwd
#
# Pure annotation only: no branch/worktree side effects, so it is safe to run
# whether starting new work or resuming an existing checkout.
#
# Linear API key: $LINEAR_API_KEY, else $XDG_CONFIG_HOME/linear/token.
set -uo pipefail

notify() {
  tmux display-message "$*"
}

read_clipboard() {
  case "$OSTYPE" in
    darwin*) pbpaste 2>/dev/null ;;
    *) wl-paste -n 2>/dev/null ;;
  esac
}

linear_token() {
  if [ -n "${LINEAR_API_KEY:-}" ]; then
    printf '%s' "$LINEAR_API_KEY"
    return 0
  fi
  local file="${XDG_CONFIG_HOME:-$HOME/.config}/linear/token"
  [ -r "$file" ] && tr -d '[:space:]' <"$file"
}

# Resolve a Linear issue. Args: IDENTIFIER (e.g. BEMLO-1234).
# On success prints "identifier<TAB>title".
resolve_linear() {
  local identifier=$1 team number token query payload response error ident title
  team=${identifier%-*}
  number=${identifier##*-}

  token=$(linear_token)
  if [ -z "$token" ]; then
    notify "No Linear API key (set \$LINEAR_API_KEY or ~/.config/linear/token)"
    return 1
  fi

  read -r -d '' query <<'GQL'
query($team: String!, $number: Float!) {
  issues(filter: { team: { key: { eq: $team } }, number: { eq: $number } }) {
    nodes { identifier title }
  }
}
GQL

  payload=$(jq -n --arg q "$query" --arg team "$team" --argjson number "$number" \
    '{query: $q, variables: {team: $team, number: $number}}')

  response=$(curl -sS -X POST https://api.linear.app/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: $token" \
    -d "$payload" 2>/dev/null)
  if [ -z "$response" ]; then
    notify "Linear API request failed (no response)"
    return 1
  fi
  error=$(printf '%s' "$response" | jq -r '.errors[0].message // empty')
  if [ -n "$error" ]; then
    notify "Linear API error: $error"
    return 1
  fi
  ident=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].identifier // empty')
  title=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].title // empty')
  if [ -z "$ident" ]; then
    notify "Issue $identifier not found"
    return 1
  fi
  printf '%s\t%s' "$ident" "$title"
}

# Fetch a GitHub title, trying PR then issue. All args are passed through to
# gh (a number, optionally followed by --repo OWNER/REPO).
gh_title() {
  gh pr view "$@" --json title -q .title 2>/dev/null || gh issue view "$@" --json title -q .title 2>/dev/null
}

# Resolve a GitHub PR/issue. Args: NUMBER [OWNER/REPO].
# Repo is inferred from the current directory when omitted.
# On success prints "#number<TAB>title".
resolve_github() {
  local number=$1 repo=${2:-} title
  if ! command -v gh >/dev/null 2>&1; then
    notify "gh is not installed"
    return 1
  fi
  if [ -n "$repo" ]; then
    title=$(gh_title "$number" --repo "$repo")
  else
    title=$(gh_title "$number")
  fi
  if [ -z "$title" ]; then
    notify "GitHub #$number not found (is gh authenticated and in a repo?)"
    return 1
  fi
  printf '#%s\t%s' "$number" "$title"
}

# Usage: tmux_set_issue [-t <window>] [<reference>]
# <reference> defaults to the clipboard; -t targets a window other than current.
main() {
  local target="" clip result issue desc tgt

  while [ $# -gt 0 ]; do
    case "$1" in
      -t)
        target=$2
        shift 2
        ;;
      *)
        clip=$1
        shift
        ;;
    esac
  done

  if [ -z "${clip:-}" ]; then
    clip=$(read_clipboard)
  fi
  clip=${clip#"${clip%%[![:space:]]*}"} # trim leading whitespace
  clip=${clip%"${clip##*[![:space:]]}"} # trim trailing whitespace
  if [ -z "$clip" ]; then
    notify "No reference given (clipboard empty)"
    exit 1
  fi

  # Dispatch by clipboard shape. GitHub URLs are matched before the Linear
  # identifier pattern so a repo name like "repo-2" can't be misread.
  if [[ "$clip" =~ github\.com/([^/]+)/([^/]+)/(pull|issues)/([0-9]+) ]]; then
    result=$(resolve_github "${BASH_REMATCH[4]}" "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}") || exit 1
  elif [[ "$clip" =~ ^#?([0-9]+)$ ]]; then
    result=$(resolve_github "${BASH_REMATCH[1]}") || exit 1
  elif [[ "$clip" =~ ([A-Za-z]+-[0-9]+) ]]; then
    local id
    id=$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')
    result=$(resolve_linear "$id") || exit 1
  else
    notify "No issue/PR reference on the clipboard"
    exit 1
  fi

  issue=${result%%$'\t'*}
  desc=${result#*$'\t'}

  tgt=()
  [ -n "$target" ] && tgt=(-t "$target")
  tmux set -w "${tgt[@]}" @issue "$issue"
  tmux set -w "${tgt[@]}" @desc "$desc"
  tmux rename-window "${tgt[@]}" "$issue"
  notify "$issue — $desc"
}

main "$@"
