#!/usr/bin/env python3
"""Waybar custom module: a scrolling CPU usage graph.

Runs continuously (no `interval` in the waybar config) and prints one JSON
line per sample, so nothing is spawned per tick. Usage is derived from
/proc/stat deltas, which is exact over the sampling interval, unlike a
short blocking sample.

The history and the last /proc/stat snapshot are kept in a small state
file under $XDG_RUNTIME_DIR, so a waybar reload neither blanks the module
until the first sample nor clears the graph: the new process prints at
once from the saved history, with a fresh sample if the snapshot is recent.

Styles:
  blocks   one sample per character, 8 levels (default; JetBrains Mono
           renders these natively, so the bars join up)
  braille  two samples per character, 4 levels each (denser, but falls
           back to DejaVu and looks dotty)
"""

import argparse
import json
import os
import subprocess
import sys
import time
from collections import deque
from pathlib import Path

STATE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "waybar-cpu-graph.json"

# 0-4 dots filled from the bottom, per braille column (dots 7,3,2,1 and 8,6,5,4)
BRAILLE_LEFT = (0x00, 0x40, 0x44, 0x46, 0x47)
BRAILLE_RIGHT = (0x00, 0x80, 0xA0, 0xB0, 0xB8)
BLOCKS = " ▁▂▃▄▅▆▇█"


def read_stat():
    """Return {cpu-name: (busy, total)} jiffies from /proc/stat."""
    out = {}
    with open("/proc/stat") as f:
        for line in f:
            if not line.startswith("cpu"):
                break
            name, *fields = line.split()
            v = [int(x) for x in fields]
            idle = v[3] + v[4]  # idle + iowait
            total = sum(v[:8])
            out[name] = (total - idle, total)
    return out


def usage(prev, cur):
    """Percent busy per cpu between two read_stat() snapshots."""
    pct = {}
    for name, (busy, total) in cur.items():
        pbusy, ptotal = prev.get(name, (busy, total))
        dt = total - ptotal
        pct[name] = 100.0 * (busy - pbusy) / dt if dt > 0 else 0.0
    return pct


SCALES = {
    # Linear keeps an idling box (5-15% on 16 cores) a flat, quiet line.
    "linear": lambda x: x,
    # Square root lifts the low end: 10% fills a third, 50% two thirds.
    "sqrt": lambda x: x**0.5,
}


def level(value, levels, scale="linear"):
    """Map 0-100 onto 0..levels; any load at all shows at least one step."""
    if value <= 0.5:
        return 0
    return max(1, min(levels, round(SCALES[scale](value / 100) * levels)))


def braille(samples, scale):
    chars = []
    for i in range(0, len(samples), 2):
        left = BRAILLE_LEFT[level(samples[i], 4, scale)]
        right = BRAILLE_RIGHT[level(samples[i + 1], 4, scale)]
        chars.append(chr(0x2800 | left | right))
    return "".join(chars)


def blocks(samples, scale):
    return "".join(BLOCKS[level(s, 8, scale)] for s in samples)


def render(samples, style, scale):
    fn = braille if style == "braille" else blocks
    return fn(samples, scale)


def theme_colour(token, fallback):
    """A colour from the desktop theme (`theme get`), for the tooltip."""
    try:
        out = subprocess.run(["theme", "get", token], capture_output=True, text=True, timeout=2)
        return out.stdout.strip() or fallback
    except Exception:
        return fallback


COLOURS = {"alert": theme_colour("alert", "#ed8796"), "note": theme_colour("note", "#f5a97f")}


def tooltip(per_core, load):
    lines = []
    cores = sorted((k for k in per_core if k != "cpu"), key=lambda k: int(k[3:]))
    for name in cores:
        pct = per_core[name]
        bar = BLOCKS[level(pct, 8)]
        colour = COLOURS["alert"] if pct >= 80 else COLOURS["note"] if pct >= 50 else None
        text = f"{name:>5} {bar} {pct:5.1f}%"
        lines.append(f'<span color="{colour}">{text}</span>' if colour else text)
    lines.append(f"load {load}")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "-w", "--width", type=int, default=20, help="graph width in characters"
    )
    ap.add_argument(
        "-i", "--interval", type=float, default=5.0, help="seconds between samples"
    )
    ap.add_argument("-s", "--style", choices=("blocks", "braille"), default="blocks")
    ap.add_argument("--scale", choices=tuple(SCALES), default="linear")
    ap.add_argument(
        "--no-percent", action="store_true", help="omit the current usage number"
    )
    args = ap.parse_args()

    per_char = 2 if args.style == "braille" else 1
    size = args.width * per_char
    history = deque([0.0] * size, maxlen=size)

    prev = read_stat()
    first = True
    # Resume from the state a previous process left, if it is for this
    # shape and recent enough for its snapshot to give a real sample.
    try:
        saved = json.loads(STATE.read_text())
        if saved.get("size") == size and saved.get("interval") == args.interval:
            history = deque(saved["history"], maxlen=size)
            if time.time() - saved["time"] < 3 * args.interval:
                prev = {k: tuple(v) for k, v in saved["stat"].items()}
                first = False  # the snapshot is fresh: sample right away
    except Exception:
        pass

    while True:
        if first:
            # Nothing to diff against yet: show the (saved) history now rather
            # than leave the module blank for an interval.
            first = False
            cur = prev
            pct = {k: 0.0 for k in cur}
            total = history[-1] if history else 0.0
        else:
            time.sleep(args.interval)
            cur = read_stat()
            pct = usage(prev, cur)
            prev = cur
            total = pct["cpu"]
            history.append(total)
            tmp = STATE.with_suffix(".tmp")
            tmp.write_text(json.dumps({"size": size, "interval": args.interval, "time": time.time(),
                                       "stat": cur, "history": list(history)}))
            tmp.replace(STATE)

        with open("/proc/loadavg") as f:
            load = " ".join(f.read().split()[:3])

        graph = render(list(history), args.style, args.scale)
        text = graph if args.no_percent else f"{graph} {total:3.0f}%"
        cls = "critical" if total >= 90 else "high" if total >= 50 else "normal"
        print(
            json.dumps(
                {
                    "text": text,
                    "tooltip": tooltip(pct, load),
                    "class": cls,
                    "percentage": round(total),
                }
            ),
            flush=True,
        )


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        sys.exit(0)
