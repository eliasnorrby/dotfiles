#!/usr/bin/env bash

# Resolve an issue/PR reference to "identifier<TAB>title" on stdout.
#
# Usage: issue_resolve [--branch-from DIR] [--with-repo] [CANDIDATE]
#
# Sources are tried in order and resolved lazily: the explicit CANDIDATE when
# given, then the clipboard, then the git branch in DIR (the current directory
# by default). The first source holding a recognizable reference wins; a source
# holding nothing recognizable is skipped, but one that is recognized and then
# fails to resolve is a hard error rather than a reason to fall through.
#
# Shape picks the resolver:
#   - Linear issue id or URL (e.g. BEMLO-1234) -> Linear GraphQL API
#   - GitHub PR/issue URL or #num (e.g. #1234) -> gh, repo inferred from cwd
#
# Output is "identifier<TAB>title". With --with-repo a third field carries the
# GitHub repo the reference belongs to (empty for Linear), which callers filing
# tasks need and the default two-field form deliberately omits.
#
# Exit status: 0 resolved, 2 no recognizable reference in any source, 1 a
# reference was recognized but could not be resolved (message on stderr).
#
# Linear API key: $LINEAR_API_KEY, else $XDG_CONFIG_HOME/linear/token.

set -uo pipefail

warn() {
  echo "$*" >&2
}

read_clipboard() {
  case "$OSTYPE" in
    darwin*) pbpaste 2>/dev/null ;;
    *) wl-paste -n 2>/dev/null ;;
  esac
}

# Print the git branch of DIR, empty when it is not a git repo.
read_git_branch() {
  local dir=$1
  [ -n "$dir" ] || return 1
  (cd "$dir" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
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
    warn "No Linear API key (set \$LINEAR_API_KEY or ~/.config/linear/token)"
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
    warn "Linear API request failed (no response)"
    return 1
  fi
  error=$(printf '%s' "$response" | jq -r '.errors[0].message // empty')
  if [ -n "$error" ]; then
    warn "Linear API error: $error"
    return 1
  fi
  ident=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].identifier // empty')
  title=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].title // empty')
  if [ -z "$ident" ]; then
    warn "Issue $identifier not found"
    return 1
  fi
  # Trailing empty repo field: Linear references have no repo, but every
  # resolver emits three fields so main can strip uniformly.
  printf '%s\t%s\t' "$ident" "$title"
}

# Fetch a GitHub title, trying PR then issue. All args are passed through to
# gh (a number, optionally followed by --repo OWNER/REPO).
gh_title() {
  gh pr view "$@" --json title -q .title 2>/dev/null || gh issue view "$@" --json title -q .title 2>/dev/null
}

# Resolve a GitHub PR/issue. Args: NUMBER [OWNER/REPO].
# Repo is inferred from the current directory when omitted.
# On success prints "#number<TAB>title<TAB>owner/repo".
resolve_github() {
  local number=$1 repo=${2:-} title
  if ! command -v gh >/dev/null 2>&1; then
    warn "gh is not installed"
    return 1
  fi
  if [ -n "$repo" ]; then
    title=$(gh_title "$number" --repo "$repo")
  else
    title=$(gh_title "$number")
    # Name the inferred repo explicitly so callers filing tasks can record it.
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
  fi
  if [ -z "$title" ]; then
    warn "GitHub #$number not found (is gh authenticated and in a repo?)"
    return 1
  fi
  printf '#%s\t%s\t%s' "$number" "$title" "$repo"
}

# Resolve a candidate string to "issue<TAB>desc" on stdout. Returns 0 on
# success, 2 when the string holds no recognizable reference (the caller may
# try another source), or 1 when a reference was recognized but could not be
# resolved (resolve_* has already warned). GitHub URLs are matched before the
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

main() {
  local branch_dir="" arg="" with_repo=false src candidate trimmed result rc

  while [ $# -gt 0 ]; do
    case "$1" in
      --branch-from)
        branch_dir=$2
        shift 2
        ;;
      --with-repo)
        with_repo=true
        shift
        ;;
      --)
        shift
        arg=${1:-}
        break
        ;;
      *)
        arg=$1
        shift
        ;;
    esac
  done

  [ -n "$branch_dir" ] || branch_dir=$PWD

  for src in arg clipboard branch; do
    case "$src" in
      arg) candidate=$arg ;;
      clipboard) candidate=$(read_clipboard) ;;
      branch) candidate=$(read_git_branch "$branch_dir") ;;
    esac
    trimmed=${candidate#"${candidate%%[![:space:]]*}"} # trim leading whitespace
    trimmed=${trimmed%"${trimmed##*[![:space:]]}"}     # trim trailing whitespace
    [ -n "$trimmed" ] || continue
    result=$(resolve_reference "$trimmed")
    rc=$?
    if [ "$rc" -eq 0 ]; then
      if [ "$with_repo" = true ]; then
        printf '%s' "$result"
      else
        printf '%s' "${result%$'\t'*}"
      fi
      return 0
    fi
    # A recognized-but-unresolvable reference is a hard error (already
    # warned); don't mask it by falling through to a lower-priority source.
    [ "$rc" -eq 1 ] && return 1
  done

  warn "No issue/PR reference found (argument, clipboard, or git branch)"
  return 2
}

main "$@"
