#!/usr/bin/env bash
# Annotate the current tmux window from an issue/PR reference.
#
# The reference comes from the first source that yields one: an explicit
# argument, the clipboard, or the active pane's git branch (e.g. a Linear
# branch like elias/bemlo-6993-... -> BEMLO-6993). Its shape picks the
# resolver, which sets the window name (@issue) plus the @desc option used by
# the pane border and window switcher:
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

# Print the git branch of the active pane: the target window's when -t is in
# play, else the current working directory (the `I` binding cd's there). Empty
# when not in a git repo. Arg: [TARGET_WINDOW].
read_git_branch() {
  local target=$1 dir
  if [ -n "$target" ]; then
    dir=$(tmux display-message -p -t "$target" '#{pane_current_path}' 2>/dev/null)
    [ -n "$dir" ] || return 1
    (cd "$dir" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
  else
    git rev-parse --abbrev-ref HEAD 2>/dev/null
  fi
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

# Resolve a candidate string to "issue<TAB>desc" on stdout. Returns 0 on
# success, 2 when the string holds no recognizable reference (the caller may
# try another source), or 1 when a reference was recognized but could not be
# resolved (resolve_* has already notified). GitHub URLs are matched before the
# Linear identifier pattern so a repo name like "repo-2" can't be misread.
resolve_reference() {
  local candidate=$1
  if [[ "$candidate" =~ github\.com/([^/]+)/([^/]+)/(pull|issues)/([0-9]+) ]]; then
    resolve_github "${BASH_REMATCH[4]}" "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  elif [[ "$candidate" =~ ^#?([0-9]+)$ ]]; then
    resolve_github "${BASH_REMATCH[1]}"
  elif [[ "$candidate" =~ ([A-Za-z]+-[0-9]+) ]]; then
    local id
    id=$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')
    resolve_linear "$id"
  else
    return 2
  fi
}

# Usage: tmux_set_issue [-t <window>] [<reference>]
# <reference> falls back to the clipboard, then the active pane's git branch;
# -t targets a window other than the current one.
main() {
  local target="" arg="" result="" issue desc tgt
  local src candidate trimmed rc

  while [ $# -gt 0 ]; do
    case "$1" in
      -t)
        target=$2
        shift 2
        ;;
      *)
        arg=$1
        shift
        ;;
    esac
  done

  # Try each source in priority order, resolving lazily so an explicit argument
  # never triggers a clipboard or git lookup. Advance to the next source only
  # when the current one holds no recognizable reference.
  for src in arg clipboard branch; do
    case "$src" in
      arg) candidate=$arg ;;
      clipboard) candidate=$(read_clipboard) ;;
      branch) candidate=$(read_git_branch "$target") ;;
    esac
    trimmed=${candidate#"${candidate%%[![:space:]]*}"} # trim leading whitespace
    trimmed=${trimmed%"${trimmed##*[![:space:]]}"}     # trim trailing whitespace
    [ -n "$trimmed" ] || continue
    result=$(resolve_reference "$trimmed")
    rc=$?
    [ "$rc" -eq 0 ] && break
    # A recognized-but-unresolvable reference is a hard error (already
    # notified); don't mask it by falling through to a lower-priority source.
    [ "$rc" -eq 1 ] && exit 1
    result=""
  done

  if [ -z "$result" ]; then
    notify "No issue/PR reference found (arg, clipboard, or git branch)"
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
