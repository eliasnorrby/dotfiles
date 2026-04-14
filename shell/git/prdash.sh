#!/usr/bin/env bash
# Usage: prdash [owner/repo]
# Shows a breakdown of open pull requests per author.
# Uses current repo if no argument given.

set -euo pipefail

repo="${1:-.}"

gh pr list --repo "$repo" --state open --limit 300 \
  --json author,isDraft,reviewDecision \
| jq -r '
  def row:
    map(tostring) | @tsv;

  (map({
    login: .author.login,
    draft: .isDraft,
    approved: (.reviewDecision == "APPROVED")
  })) as $prs |

  ($prs | length) as $total |
  ($prs | map(select(.draft)) | length) as $drafts |
  ($prs | map(select(.draft | not) | select(.approved | not)) | length) as $pending |
  ($prs | map(select(.approved)) | length) as $approved |

  ["Author", "PRs", "Drafts", "Pending", "Approved"] | @tsv,
  (["TOTAL", $total, $drafts, $pending, $approved] | row),
  (
    $prs
    | group_by(.login)
    | sort_by(-length)[]
    | [
        .[0].login,
        length,
        (map(select(.draft)) | length),
        (map(select(.draft | not) | select(.approved | not)) | length),
        (map(select(.approved)) | length)
      ]
    | row
  )
' | column -t
