#!/usr/bin/env python3
"""Render fetched PR JSON as compact markdown for digest agents.
usage: pr_render.py [--focus REGEX] FILE.json...
With --focus, a PR whose title doesn't match keeps only the comments and threads that do."""
import json, re, sys
focus = None
if sys.argv[1] == "--focus": focus = re.compile(sys.argv[2], re.I); del sys.argv[1:3]
BOT = re.compile(r"bot|copilot|coderabbit|linear|github-actions|sonarcloud|vercel|claude|netlify|dependabot|renovate|codecov|cursor|graphite|gemini", re.I)
def who(c): return (c.get("author") or {}).get("login") or "ghost"
def human(c): return c.get("body") and not BOT.search(who(c))
def clip(s, n): s = (s or "").strip(); return s if len(s) <= n else s[:n] + " …[clipped]"
for f in sys.argv[1:]:
    p = json.load(open(f))
    narrow = focus is not None and not focus.search(p["title"])
    keep = (lambda c: human(c) and focus.search(c["body"])) if narrow else human
    state = "merged " + p["mergedAt"][:10] if p.get("mergedAt") else p["state"].lower()
    print(f"\n# {p['repo']}#{p['number']} {p['title']}\n")
    print(f"{p['url']} | by {who(p)} | opened {p['createdAt'][:10]} | {state} | +{p['additions']} -{p['deletions']}")
    iss = [f"#{i['number']} {i['title']}" for i in p["closingIssuesReferences"]["nodes"]]
    if iss: print("Closes: " + "; ".join(iss))
    dirs = {}
    for x in p["files"]["nodes"]:
        d = "/".join(x["path"].split("/")[:4]); dirs[d] = dirs.get(d, 0) + 1
    print("Files: " + ", ".join(f"{d} ({n})" for d, n in sorted(dirs.items(), key=lambda kv: -kv[1])[:12]))
    if narrow: print("(Focused: only discussion matching the topic is shown.)")
    if p.get("body"): print("\n## Body\n" + clip(p["body"], 2500 if narrow else 5000))
    conv = [c for c in p["comments"]["nodes"] if keep(c)] + [dict(c, createdAt=c.get("submittedAt")) for c in p["reviews"]["nodes"] if keep(c)]
    if conv:
        print("\n## Conversation")
        for c in sorted(conv, key=lambda c: c.get("createdAt") or ""):
            print(f"\n**{who(c)}** {(c.get('createdAt') or '')[:10]} {c.get('state','')}:\n{clip(c['body'], 4000)}")
    ts = [t for t in p["reviewThreads"]["nodes"] if any(keep(c) for c in t["comments"]["nodes"])]
    if ts:
        print("\n## Review threads")
        for t in ts:
            print(f"\n### {t['path']}:{t.get('line')} ({'resolved' if t['isResolved'] else 'open'})")
            for c in t["comments"]["nodes"]:
                if human(c): print(f"- **{who(c)}** {c['createdAt'][:10]}: {clip(c['body'], 4000)}")
