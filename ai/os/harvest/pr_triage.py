#!/usr/bin/env python3
"""Score fetched PRs on discussion signals. usage: pr_triage.py JSONDIR [relevance-regex] > scores.tsv"""
import json, glob, re, sys
ME = "eliasnorrby"
BOT = re.compile(r"bot|copilot|coderabbit|linear|github-actions|sonarcloud|vercel|claude|netlify|dependabot|renovate|codecov|cursor|graphite|gemini", re.I)
rel = re.compile(sys.argv[2], re.I) if len(sys.argv) > 2 else None
print("\t".join("repo num created author me maxlen human_chars threads resolved body rel title".split()))
for f in sorted(glob.glob(sys.argv[1] + "/*.json")):
    p = json.load(open(f))
    author = (p.get("author") or {}).get("login") or "?"
    human = []
    for c in p["comments"]["nodes"] + p["reviews"]["nodes"]:
        human.append(c)
    threads = p["reviewThreads"]["nodes"]
    for t in threads: human += t["comments"]["nodes"]
    human = [c for c in human if c.get("body") and not BOT.search((c.get("author") or {}).get("login") or "bot")]
    me = "A" if author == ME else ("R" if any((c.get("author") or {}).get("login") == ME for c in human) else "-")
    lens = [len(c["body"]) for c in human]
    text = (p["title"] or "") + (p["body"] or "") + " ".join(c["body"] for c in human) + " ".join(x["path"] for x in p["files"]["nodes"])
    r = len(rel.findall(text)) if rel else 0
    print("\t".join(map(str, [p["repo"], p["number"], p["createdAt"][:10], author, me, max(lens or [0]), sum(lens),
        len(threads), sum(t["isResolved"] for t in threads), len(p["body"] or ""), r, p["title"]])))
