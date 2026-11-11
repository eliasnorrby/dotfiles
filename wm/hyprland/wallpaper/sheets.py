#!/usr/bin/env python3
"""Render the carborange sheets wallpaper: four sheets of grey stacked from
the left over the ground, each edge a straight line tilted 67.5 degrees from horizontal
(rising to the right), each sheet casting a soft shadow on the one beneath.
Everything is computed in floating point and dithered once at the end, so
the shallow gradients do not band.

    uv run --with numpy,pillow sheets.py [WIDTH HEIGHT] [OUT]

Defaults to 3840x2160, written as sheets.png next to this script; the
copy hyprpaper uses lives in Dropbox (see hyprpaper.conf), so pass that
path as OUT when re-rendering.
"""

import math
import os
import sys

import numpy as np
from PIL import Image

# Ground, right of the last sheet: a shallow gradient darkened at the corners.
GROUND_LEFT = (0x39, 0x3D, 0x44)   # surface2
GROUND_RIGHT = (0x30, 0x34, 0x3A)  # surface2, a shade down
VIGNETTE = (0x14, 0x16, 0x1A)      # mantle
VIGNETTE_STRENGTH = 0.45

# Sheets, left to right: (edge x at mid height as a fraction of width,
# colour). Each sheet covers everything left of its edge and is painted on
# top of the sheets to its right.
# Four edges, five pieces of material counting the ground. An edge's
# horizontal reach over the full height is (height / 2) / tan(tilt) on each
# side of its mid-height x, about 0.116 of the width here, so edges at
# 0.29 and 0.71 leave the same margin bottom-left and top-right.
SHEETS = [
    (0.29, (0x0B, 0x0C, 0x0F)),  # below crust
    (0.43, (0x14, 0x16, 0x1A)),  # mantle
    (0.57, (0x1E, 0x21, 0x26)),  # between base and surface0
    (0.71, (0x2B, 0x2E, 0x34)),  # surface1
]
TILT_DEG = 67.5
SHADOW_WIDTH = 0.030   # of width; how far the shadow reaches right of an edge
SHADOW_DEPTH = 0.55    # how dark it gets at the edge, 0..1
EDGE_LIFT = 0.12       # how much a sheet brightens toward its own edge
LIFT_WIDTH = 0.22      # of width; the band over which the lift fades in


def render(width, height):
    ys, xs = np.mgrid[0:height, 0:width].astype(np.float32)
    nx = xs / width

    # Ground.
    t = nx[..., None]
    img = (1 - t) * np.array(GROUND_LEFT, np.float32) + t * np.array(GROUND_RIGHT, np.float32)
    r = np.hypot((xs - width / 2) / (width / 2), (ys - height / 2) / (height / 2))
    v = np.clip((r - 0.55) / 0.9, 0, 1) ** 1.6 * VIGNETTE_STRENGTH
    img = img * (1 - v[..., None]) + np.array(VIGNETTE, np.float32) * v[..., None]

    # Signed distance from an edge: positive to the right of it. The edge
    # rises to the right, so at the top it sits further right than at the
    # bottom.
    slope = 1 / math.tan(math.radians(TILT_DEG))
    norm = 1 / math.sqrt(1 + slope * slope)
    for frac, colour in reversed(SHEETS):
        edge_x = frac * width + (height / 2 - ys) * slope
        d = (xs - edge_x) * norm
        # Shadow on whatever is underneath, right of the edge.
        s = np.exp(-np.clip(d, 0, None) / (SHADOW_WIDTH * width)) * SHADOW_DEPTH
        s = np.where(d > 0, s, 0)[..., None]
        img = img * (1 - s)
        # The sheet itself, lifted toward its edge, anti-aliased at the edge.
        lift = np.clip(1 + d / (LIFT_WIDTH * width), 0, 1) * EDGE_LIFT
        sheet = np.array(colour, np.float32) * (1 + lift[..., None]) + 4 * lift[..., None]
        cover = np.clip(0.5 - d, 0, 1)[..., None]
        img = img * (1 - cover) + sheet * cover

    rng = np.random.default_rng(7)
    img = img + rng.uniform(-0.5, 0.5, img.shape).astype(np.float32)
    return Image.fromarray(np.clip(np.rint(img), 0, 255).astype(np.uint8), "RGB")


def main():
    args = sys.argv[1:]
    width, height = 3840, 2160
    if len(args) >= 2:
        width, height = int(args[0]), int(args[1])
        args = args[2:]
    out = args[0] if args else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "sheets.png")
    render(width, height).save(out, optimize=True)
    print(out)


if __name__ == "__main__":
    main()
