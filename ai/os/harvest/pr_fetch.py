#!/usr/bin/env python3
"""Fetch PRs (title, body, files, comments, reviews, review threads) as JSON, one file per PR.
usage: pr_fetch.py OUTDIR < lines of "owner/repo<TAB>number..." """
import json, subprocess, sys, os
out = sys.argv[1]; os.makedirs(out, exist_ok=True)
FIELDS = """number title url state createdAt mergedAt closedAt author{login} body additions deletions
 baseRefName headRefName
 files(first:100){nodes{path additions deletions}}
 closingIssuesReferences(first:10){nodes{number title}}
 comments(first:100){nodes{author{login} createdAt body}}
 reviews(first:50){nodes{author{login} state submittedAt body}}
 reviewThreads(first:100){nodes{isResolved path line comments(first:50){nodes{author{login} createdAt body}}}}"""
todo = []
for line in sys.stdin:
    repo, num = line.split("\t")[:2]
    f = f"{out}/{repo.replace('/', '__')}__{num}.json"
    if not os.path.exists(f): todo.append((repo, int(num), f))
for i in range(0, len(todo), 8):
    chunk = todo[i:i+8]
    q = "query{" + " ".join(
        f'p{j}:repository(owner:"{r.split("/")[0]}",name:"{r.split("/")[1]}"){{pullRequest(number:{n}){{{FIELDS}}}}}'
        for j, (r, n, _) in enumerate(chunk)) + "}"
    res = subprocess.run(["gh", "api", "graphql", "-f", f"query={q}"], capture_output=True, text=True)
    data = json.loads(res.stdout or "{}").get("data") or {}
    for j, (r, n, f) in enumerate(chunk):
        pr = (data.get(f"p{j}") or {}).get("pullRequest")
        if pr:
            pr["repo"] = r
            json.dump(pr, open(f, "w"), ensure_ascii=False, indent=1)
        else:
            print(f"failed {r}#{n}: {res.stderr[:200]}", file=sys.stderr)
    print(f"{min(i+8, len(todo))}/{len(todo)}", file=sys.stderr)
