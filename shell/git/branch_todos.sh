#!/bin/bash

# This script will find all TODO comments in the current branch that are not in master
# and output them in a format that can be consumed by Vim's quickfix list.

# Find the common ancestor between the current branch and master
ancestor=$(git merge-base master "$(git branch --show-current)")

# Get the diff of all files with changes, focusing on added TODOs
git diff -U0 "$ancestor"..HEAD | awk '
  # Track the current file name based on the diff headers
  /^diff --git a\// {
    file = $3
    sub(/^a\//, "", file)
  }

  # Track line numbers from the hunk header
  /^@@/ {
    split($0, arr, " ")
    split(arr[2], lines, ",")
    current_line = substr(lines[1], 2)  # Remove the leading minus
  }

  # For lines added or removed, adjust the baseline
  /^\+/ {
    current_line++
  }

  /^-/ {
    current_line--
  }

  # Process added lines containing TODO
  /^\+/ && /TODO/ {
    todo_comment = $0
    sub(/^.*TODO/, "TODO", todo_comment)

    # Print the file, line number, and TODO comment in quickfix format
    print file ":" current_line ":1: " todo_comment
  }
'
