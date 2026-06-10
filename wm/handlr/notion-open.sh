#!/bin/sh
# Open a notion.so URL in the native Notion desktop app by rewriting it to
# Notion's custom scheme (https://www.notion.so/X -> notion://www.notion.so/X).
url="$1"
exec notion-app "notion://${url#http*://}"
