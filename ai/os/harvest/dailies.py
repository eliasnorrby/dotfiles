#!/usr/bin/env python3
"""Create or extend thin backfilled dailies from timeline lines "- YYYY-MM-DD — what — Page[; Page]".
usage: dailies.py VAULT < timeline.md   (prints the files it touched)"""
import os, re, sys
vault = sys.argv[1]
days = {}
for line in sys.stdin:
    m = re.match(r"- (\d{4}-\d{2}-\d{2}) — (.+) — (.+)$", line.strip())
    if not m: continue
    date, what, pages = m.groups()
    links = [p.strip() for p in pages.split(";")]
    head, rest = f"[[{links[0]}]]", "".join(f"; see also [[{p}]]" for p in links[1:])
    days.setdefault(date, []).append(f"- {head} — {what}{rest}")
for date, bullets in sorted(days.items()):
    path = f"{vault}/dailies/{date}.md"
    if os.path.exists(path):
        text = open(path).read()
        new = [b for b in bullets if b not in text]
        if not new: continue
        head, sep, tail = text.partition("\n## Jots")
        text = head.rstrip("\n") + "\n\n" + "\n\n".join(new) + "\n" + sep + tail
    else:
        text = (f"---\ntype: daily\ncreated: {date}\n---\n\n# {date}\n\n## Worked on\n\n"
                + "\n\n".join(bullets) + "\n\n## Jots\n")
    open(path, "w").write(text)
    print(os.path.relpath(path, vault))
