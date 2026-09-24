#!/usr/bin/env python3
"""Add index.md lines for wiki pages, topics and people that have none.

usage: index_fill.py VAULT [--dry-run]

Existing lines are left alone. A page goes under `## Pages` → `### <its up: hub>`
(or `### Loose`), with the summary its hub's `## Pages` section gives it; a topic
goes under `## Topics` → the `###` group for its kind; a person under `## People`.
Summaries fall back to the first sentence after the H1. Prints what it added.
"""
import os
import re
import sys

vault = sys.argv[1]
dry = "--dry-run" in sys.argv
KIND_GROUP = {"investigation": "Investigations", "system": "Systems", "concept": "Concepts",
              "customer": "Customers", "other": "Other"}


def read(path):
    return open(path, encoding="utf-8").read()


def front(text):
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    fm = {}
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                fm[k.strip()] = v.strip().strip('"')
    return fm


def first_sentence(text):
    body = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.S)
    body = re.sub(r"^# .*\n", "", body, count=1, flags=re.M).strip()
    para = body.split("\n\n")[0].replace("\n", " ")
    para = re.sub(r"\[\[([^\]|]+)\|([^\]]+)\]\]", r"\2", para)
    para = re.sub(r"\[\[([^\]]+)\]\]", r"\1", para)
    s = re.split(r"(?<=[.!?])\s", para, maxsplit=1)[0]
    return s[:220].rstrip(" .") if s else ""


def hub_summaries():
    out = {}
    for d in ("wiki/topics", "wiki/pages"):
        for f in os.listdir(os.path.join(vault, d)):
            if not f.endswith(".md"):
                continue
            t = read(os.path.join(vault, d, f))
            sec = re.search(r"^## Pages\n(.*?)(?=^## |\Z)", t, re.S | re.M)
            if not sec:
                continue
            for m in re.finditer(r"^\s*- \[\[([^\]|]+)(?:\|[^\]]*)?\]\]\s*[—–-]\s*(.+)$", sec.group(1), re.M):
                out.setdefault(m.group(1).strip(), m.group(2).strip())
    return out


index_path = os.path.join(vault, "index.md")
index = read(index_path)
listed = set(re.findall(r"^- \[\[([^\]|]+)", index, re.M))
summ = hub_summaries()


def add_line(text, section, group, line):
    """Insert line at the end of `### group` inside `## section`, creating the group if needed."""
    sec = re.search(rf"^## {re.escape(section)}\n.*?(?=^## |\Z)", text, re.S | re.M)
    if not sec:
        text = text.rstrip("\n") + f"\n\n## {section}\n"
        sec = re.search(rf"^## {re.escape(section)}\n.*?(?=^## |\Z)", text, re.S | re.M)
    s, e = sec.span()
    block = text[s:e]
    if group:
        g = re.search(rf"^### {re.escape(group)}\n.*?(?=^### |\Z)", block, re.S | re.M)
        if g:
            gs, ge = g.span()
            gb = block[gs:ge].rstrip("\n") + "\n" + line + "\n\n"
            block = block[:gs] + gb + block[ge:]
        else:
            loose = re.search(r"^### Loose\n", block, re.M)
            new = f"### {group}\n\n{line}\n\n"
            block = (block[:loose.start()] + new + block[loose.start():]) if loose and group != "Loose" \
                else block.rstrip("\n") + "\n\n" + new
    else:
        block = block.rstrip("\n") + "\n" + line + "\n\n"
    return text[:s] + block + text[e:]


added = []
for sub, section in (("topics", "Topics"), ("pages", "Pages"), ("people", "People")):
    d = os.path.join(vault, "wiki", sub)
    for f in sorted(os.listdir(d)):
        if not f.endswith(".md"):
            continue
        title = f[:-3]
        if title in listed:
            continue
        t = read(os.path.join(d, f))
        fm = front(t)
        if sub == "topics":
            group = KIND_GROUP.get(fm.get("kind", "other"), "Other")
            summary = first_sentence(t)
        elif sub == "pages":
            up = re.match(r"\[\[([^\]|]+)", fm.get("up", ""))
            group = up.group(1) if up else "Loose"
            summary = summ.get(title) or first_sentence(t)
        else:
            group = None
            summary = "; ".join(x for x in (fm.get("org"), fm.get("role")) if x) or first_sentence(t)
        line = f"- [[{title}]] — {summary}"
        index = add_line(index, section, group, line)
        added.append(f"{section}/{group or ''}: {title}")
        listed.add(title)

if not dry:
    open(index_path, "w", encoding="utf-8").write(index)
print("\n".join(added))
print(f"{len(added)} lines added" + (" (dry run)" if dry else ""))
