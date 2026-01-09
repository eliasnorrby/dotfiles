#!/bin/sh

# special_paste.sh - Type URL identifier and convert to hyperlink
#
# Reads clipboard content (expected URL), extracts identifier:
# - GitHub: github.com/.../123 -> #123
# - Linear: linear.app/.../PROJ-123/... -> PROJ-123
# - Notion: notion.so/.../Page-Name-uuid -> Page Name
#
# Types the identifier, selects it, pastes the URL to create a hyperlink.

DELAY_MS=10

notify_error() {
  notify-send -u normal -t 3000 "Special Paste" "$1"
}

get_clipboard() {
  wl-paste --no-newline 2>/dev/null
}

# Extract identifier from URL
# Output format: type:identifier:word_count
parse_url() {
  url="$1"

  # GitHub: extract PR/issue number
  if echo "$url" | grep -qE 'github\.com/.*/[0-9]+'; then
    number=$(echo "$url" | sed -n 's|.*github\.com/.*/\([0-9]\+\).*|\1|p')
    if [ -n "$number" ]; then
      echo "github:${number}:1"
      return 0
    fi
  fi

  # Linear: extract issue tag (e.g., PROJ-123)
  if echo "$url" | grep -qE 'linear\.app/[^/]+/issue/[A-Z]+-[0-9]+'; then
    tag=$(echo "$url" | sed -n 's|.*linear\.app/[^/]*/issue/\([A-Z]*-[0-9]*\).*|\1|p')
    if [ -n "$tag" ]; then
      echo "linear:${tag}:1"
      return 0
    fi
  fi

  # Notion: extract page name (remove UUID suffix)
  if echo "$url" | grep -qE 'notion\.so/[^/]+/[a-zA-Z0-9-]+'; then
    page_slug=$(echo "$url" | sed -n 's|.*notion\.so/[^/]*/\([a-zA-Z0-9-]*\).*|\1|p')
    if [ -n "$page_slug" ]; then
      # Remove last segment (UUID) and convert dashes to spaces
      page_name=$(echo "$page_slug" | sed 's/-[a-f0-9]*$//' | tr '-' ' ')
      word_count=$(echo "$page_name" | wc -w)
      echo "notion:${page_name}:${word_count}"
      return 0
    fi
  fi

  return 1
}

type_text() {
  text="$1"
  wtype -d "$DELAY_MS" "$text"
}

select_words() {
  url_type="$1"
  count="$2"
  i=0
  while [ "$i" -lt "$count" ]; do
    wtype -d "$DELAY_MS" -M ctrl -M shift -k Left -m ctrl -m shift
    i=$((i + 1))
  done
  # For GitHub, extend selection by one char to include the '#'
  if [ "$url_type" = "github" ]; then
    wtype -d "$DELAY_MS" -M shift -k Left -m shift
  fi
}

paste_and_move() {
  wtype -d "$DELAY_MS" -M ctrl -k v -m ctrl
  wtype -d "$DELAY_MS" -k Right
}

main() {
  clipboard=$(get_clipboard)

  if [ -z "$clipboard" ]; then
    notify_error "Clipboard is empty"
    exit 1
  fi

  parsed=$(parse_url "$clipboard")

  if [ -z "$parsed" ]; then
    notify_error "Clipboard does not contain a supported URL"
    exit 1
  fi

  url_type=$(echo "$parsed" | cut -d: -f1)
  identifier=$(echo "$parsed" | cut -d: -f2)
  word_count=$(echo "$parsed" | cut -d: -f3)

  # Type the identifier (with prefix for GitHub)
  if [ "$url_type" = "github" ]; then
    wtype -d "$DELAY_MS" '\#'
  fi
  type_text "$identifier"

  # Select the typed text (word by word)
  select_words "$url_type" "$word_count"

  # Paste the URL over the selection
  paste_and_move
}

main
