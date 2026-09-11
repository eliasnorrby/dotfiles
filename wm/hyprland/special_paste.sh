#!/bin/sh

# special_paste.sh - Paste the clipboard URL as a rich-text hyperlink
#
# Reads clipboard content (expected URL), extracts a label:
# - GitHub: github.com/.../123 -> #123
# - Linear: linear.app/.../PROJ-123/... -> PROJ-123
# - Notion: notion.so/.../Page-Name-uuid -> Page Name
#
# Offers <a href="url">label</a> as text/html on the clipboard and sends
# Ctrl+V with sendshortcut, so rich-text targets (Slack, Linear, Notion,
# ...) insert a finished hyperlink. The original clipboard is restored
# afterwards. No wtype: virtual keyboards hijack the active xkb layout,
# and injected chords collide with modifiers still held by the user.
#
# --print: print the generated html and exit (for testing).

notify_error() {
  notify-send -u normal -t 3000 "Special Paste" "$1"
}

get_clipboard() {
  wl-paste --no-newline 2>/dev/null
}

html_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
}

# Extract a display label from URL
parse_url() {
  url="$1"

  # GitHub: extract PR/issue number
  if echo "$url" | grep -qE 'github\.com/.*/[0-9]+'; then
    number=$(echo "$url" | sed -n 's|.*github\.com/.*/\([0-9]\+\).*|\1|p')
    if [ -n "$number" ]; then
      echo "#${number}"
      return 0
    fi
  fi

  # Linear: extract issue tag (e.g., PROJ-123)
  if echo "$url" | grep -qE 'linear\.app/[^/]+/issue/[A-Z]+-[0-9]+'; then
    tag=$(echo "$url" | sed -n 's|.*linear\.app/[^/]*/issue/\([A-Z]*-[0-9]*\).*|\1|p')
    if [ -n "$tag" ]; then
      echo "$tag"
      return 0
    fi
  fi

  # Notion: extract page name (remove UUID suffix); handles both the old
  # notion.so/<ws>/<slug> and the new app.notion.com/p/<ws>/<slug> links
  if echo "$url" | grep -qE 'notion\.(so|com)/(p/)?[^/]+/[a-zA-Z0-9-]+'; then
    page_slug=$(echo "$url" | sed -nE 's#.*notion\.(so|com)/(p/)?[^/]+/([a-zA-Z0-9-]+).*#\3#p')
    if [ -n "$page_slug" ]; then
      # Remove last segment (UUID) and convert dashes to spaces
      echo "$page_slug" | sed 's/-[a-f0-9]*$//' | tr '-' ' '
      return 0
    fi
  fi

  return 1
}

main() {
  clipboard=$(get_clipboard)

  if [ -z "$clipboard" ]; then
    notify_error "Clipboard is empty"
    exit 1
  fi

  label=$(parse_url "$clipboard")

  if [ -z "$label" ]; then
    notify_error "Clipboard does not contain a supported URL"
    exit 1
  fi

  html="<a href=\"$(html_escape "$clipboard")\">$(html_escape "$label")</a>"

  if [ "$1" = "--print" ]; then
    printf '%s\n' "$html"
    exit 0
  fi

  printf '%s' "$html" | wl-copy --type text/html
  # Let wl-copy take clipboard ownership before pasting
  sleep 0.2
  hyprctl dispatch sendshortcut "CTRL, V, activewindow" >/dev/null

  # Give the target time to fetch the offer, then restore the clipboard
  sleep 0.5
  printf '%s' "$clipboard" | wl-copy

  # Scrub the intermediate html offer from clipboard history
  command -v cliphist >/dev/null && cliphist delete-query "$html" 2>/dev/null
}

main "$@"
