#!/usr/bin/env python3
"""List PRs a user authored, reviewed or commented on in a repo, month by month (search caps at 1000).
usage: pr_list.py REPO USER FROM(YYYY-MM) TO(YYYY-MM) > out.tsv"""
import json, subprocess, sys, time, datetime as dt

repo, user, frm, to = sys.argv[1:5]


def months(a, b):
    y, m = map(int, a.split("-"))
    yb, mb = map(int, b.split("-"))
    while (y, m) <= (yb, mb):
        ny, nm = (y + (m == 12), m % 12 + 1)
        yield dt.date(y, m, 1), dt.date(ny, nm, 1) - dt.timedelta(days=1)
        y, m = ny, nm


seen = set()
for s, e in months(frm, to):
    for who in ("author", "reviewed-by", "commenter"):
        q = f"repo:{repo} is:pr {who}:{user} created:{s}..{e}"
        for page in range(1, 11):
            for attempt in range(6):
                r = subprocess.run(["gh", "api", "-X", "GET", "search/issues", "-f", f"q={q}",
                                    "-f", "per_page=100", "-f", f"page={page}"], capture_output=True, text=True)
                if r.returncode == 0:
                    break
                print(f"retry {q} p{page}: {r.stderr.strip()[:120]}", file=sys.stderr, flush=True)
                time.sleep(20 * (attempt + 1))
            else:
                print(f"FAILED {q}", file=sys.stderr, flush=True)
                break
            items = json.loads(r.stdout)["items"]
            for it in items:
                if it["number"] not in seen:
                    seen.add(it["number"])
                    print(f"{repo}\t{it['number']}\t{it['created_at'][:10]}", flush=True)
            time.sleep(2.2)
            if len(items) < 100:
                break
    print(f"{s:%Y-%m} done, {len(seen)} total", file=sys.stderr, flush=True)
