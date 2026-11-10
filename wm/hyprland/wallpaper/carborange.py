#!/usr/bin/env python3
"""Render the carborange wallpaper: a dot grid on carbon that fades toward
the centre, so a transparent terminal sits on near-flat grey and the grid
shows in the gaps.

    carborange.py [WIDTH HEIGHT] [OUT]

Defaults to 3840x2160 next to this script.
"""

import math
import os
import sys

from PIL import Image, ImageDraw

GROUND = (0x0F, 0x11, 0x15)
DOT = (0x2B, 0x2E, 0x34)
PITCH = 64  # physical px; 43 logical at 1.5x
RADIUS = 2.6


def render(width, height):
    img = Image.new("RGB", (width, height), GROUND)
    draw = ImageDraw.Draw(img)
    cx, cy = width / 2, height / 2
    maxd = math.hypot(cx, cy)
    y = PITCH / 2
    while y < height:
        x = PITCH / 2
        while x < width:
            d = math.hypot(x - cx, y - cy) / maxd
            t = max(0.0, min(1.0, (d - 0.2) / 0.65))
            a = 0.3 + t * 0.7
            c = tuple(round(g + (p - g) * a) for g, p in zip(GROUND, DOT))
            draw.ellipse(
                (x - RADIUS, y - RADIUS, x + RADIUS, y + RADIUS), fill=c
            )
            x += PITCH
        y += PITCH
    return img


def main():
    args = sys.argv[1:]
    width, height = 3840, 2160
    if len(args) >= 2:
        width, height = int(args[0]), int(args[1])
        args = args[2:]
    out = args[0] if args else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "carborange.png"
    )
    render(width, height).save(out, optimize=True)
    print(out)


if __name__ == "__main__":
    main()
