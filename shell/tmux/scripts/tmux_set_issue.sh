#!/usr/bin/env bash
# Annotate the current tmux window from a Linear issue on the clipboard.
#
# Reads a Linear issue identifier (e.g. BEMLO-1234, or any string/URL
# containing one) from the clipboard, fetches its title via the Linear
# GraphQL API, and sets the window name (@issue identifier) plus the @desc
# option used by the pane border and window switcher.
#
# The API key is read from $LINEAR_API_KEY, falling back to a file at
# $XDG_CONFIG_HOME/linear/token (chmod 600, never committed).
set -uo pipefail

notify() {
  tmux display-message "$*"
}

# --- clipboard -------------------------------------------------------------
case "$OSTYPE" in
  darwin*) clip=$(pbpaste 2>/dev/null) ;;
  *) clip=$(wl-paste -n 2>/dev/null) ;;
esac

# Extract the first issue identifier (case-insensitive), normalise to upper.
identifier=$(printf '%s' "$clip" | grep -oiE '[a-z]+-[0-9]+' | head -n1 | tr '[:lower:]' '[:upper:]')
if [ -z "$identifier" ]; then
  notify "No Linear issue identifier found on the clipboard"
  exit 1
fi

team=${identifier%-*}
number=${identifier##*-}

# --- API key ---------------------------------------------------------------
api_key=${LINEAR_API_KEY:-}
if [ -z "$api_key" ]; then
  key_file="${XDG_CONFIG_HOME:-$HOME/.config}/linear/token"
  [ -r "$key_file" ] && api_key=$(tr -d '[:space:]' <"$key_file")
fi
if [ -z "$api_key" ]; then
  notify "No Linear API key (set \$LINEAR_API_KEY or ~/.config/linear/token)"
  exit 1
fi

# --- fetch issue -----------------------------------------------------------
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
  -H "Authorization: $api_key" \
  -d "$payload" 2>/dev/null)

if [ -z "$response" ]; then
  notify "Linear API request failed (no response)"
  exit 1
fi

error=$(printf '%s' "$response" | jq -r '.errors[0].message // empty')
if [ -n "$error" ]; then
  notify "Linear API error: $error"
  exit 1
fi

ident=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].identifier // empty')
title=$(printf '%s' "$response" | jq -r '.data.issues.nodes[0].title // empty')
if [ -z "$ident" ]; then
  notify "Issue $identifier not found"
  exit 1
fi

# --- annotate --------------------------------------------------------------
tmux set -w @issue "$ident"
tmux set -w @desc "$title"
tmux rename-window "$ident"
notify "$ident — $title"
