#!/usr/bin/env python3
"""userstyles: the catppuccin userstyles, recoloured for a theme.

Every catppuccin userstyle takes its colours from one shared LESS file
(the "std" lib) and picks a flavour by name. A theme keeps the 26 names,
so a userstyle is rendered by inlining a copy of that lib in which the
theme's flavour carries the theme's colours and the accent is the theme's
accent. `theme build` calls this for every theme; the rendered styles land
in the theme's output dir, and `userstyles serve` (a user unit on arch)
serves $XDG_CONFIG_HOME/theme on localhost. Each style's update URL points
at its file under current/ there, so Stylus pulls the current theme's
version on its next update check ("Check all styles for updates" in the
manager, or the interval in its options). Stylus only downloads over http
and https, which is why a server and not a file URL; localhost is exempt
from its rule that an update's version must grow.

    userstyles build THEME [--refresh]   render styles.txt for the theme
    userstyles serve                     serve ~/.config/theme on localhost
    userstyles fetch                     refresh the upstream sources
    userstyles list                      the styles, and which are cached
    userstyles filter HEX...             the CSS filter chain for a colour

The sites are the slugs in styles.txt, one per line (the directory names
under styles/ in github.com/catppuccin/userstyles). A site's own touches
go in overrides/<slug>.less: LESS in the theme's {{token}} syntax, rendered
with the palette and appended after the upstream code, so a declaration on
the same selectors wins. Sources are fetched
once into $XDG_CACHE_HOME/userstyles and refreshed by `fetch`; a build
never needs the network when the cache is warm, and a style whose source
is missing is skipped with a warning rather than failing the build.

Setup, once per machine: import <theme dir>/userstyles/import.json from
the Stylus manager's Backup section. Styles with the same name are
replaced in place, and Stylus offers to remove the ones the import leaves
out. Re-import whenever styles.txt changes; a switch needs no import.

Standard library only; the palette comes from base/theme/theme.py.
"""

import hashlib
import importlib.util
import json
import math
import os
import random
import re
import shutil
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
STYLES = HERE / "styles.txt"
OVERRIDES = HERE / "overrides"
PRESETS = HERE / "presets"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "userstyles"
PORT = 7414  # loopback only; the update URLs carry it

UPSTREAM = "https://github.com/catppuccin/userstyles/raw/main/styles/{slug}/catppuccin.user.less"
STD_URL = "https://userstyles.catppuccin.com/lib/std/v1.less"
STD_IMPORT = re.compile(r'^@import\s+"' + re.escape(STD_URL) + r'";\s*$', re.M)
NAMES = ("rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue "
         "lavender text subtext1 subtext0 overlay2 overlay1 overlay0 surface2 surface1 surface0 "
         "base mantle crust").split()


def theme_module():
    """base/theme/theme.py, for the palette and the current-theme paths."""
    path = HERE.parent.parent / "base/theme/theme.py"
    if not path.exists():
        exe = shutil.which("theme")
        if not exe:
            sys.exit("userstyles: theme.py not found")
        path = Path(exe).resolve()
    spec = importlib.util.spec_from_file_location("theme", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def slugs():
    out = []
    for line in STYLES.read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            out.append(line)
    return out


def fetch(url, dest):
    with urllib.request.urlopen(url, timeout=15) as r:
        data = r.read()
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(data)


def source(slug, refresh=False):
    """The upstream text of one style, from the cache or the network."""
    cached = CACHE / f"{slug}.user.less"
    if refresh or not cached.exists():
        try:
            fetch(UPSTREAM.format(slug=slug), cached)
        except Exception as e:
            if cached.exists():
                print(f"userstyles: {slug}: using the cached copy ({e})", file=sys.stderr)
            else:
                print(f"userstyles: {slug}: no source ({e}), skipped", file=sys.stderr)
                return None
    return cached.read_text()


def std(refresh=False):
    """The shared palette lib: cached, or the committed copy when offline."""
    cached = CACHE / "std-v1.less"
    if refresh or not cached.exists():
        try:
            fetch(STD_URL, cached)
        except Exception as e:
            print(f"userstyles: std lib: using the committed copy ({e})", file=sys.stderr)
            return (PRESETS / "std-v1.less").read_text()
    return cached.read_text()


# --- CSS filters -----------------------------------------------------------
# The lib carries, per colour, a filter chain that turns a black image into
# that colour (for recolouring logos and icons). This is the usual solver
# for them (Barrett Sonntag's, as catppuccin uses): SPSA over
# invert/sepia/saturate/hue-rotate/brightness/contrast against the colour
# distance in RGB and HSL. Results are cached by hex, so a colour is solved
# once per machine.


class Color:
    def __init__(self, r=0, g=0, b=0):
        self.r, self.g, self.b = r, g, b

    def set(self, r, g, b):
        self.r, self.g, self.b = max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b))

    def multiply(self, m):
        r = self.r * m[0] + self.g * m[1] + self.b * m[2]
        g = self.r * m[3] + self.g * m[4] + self.b * m[5]
        b = self.r * m[6] + self.g * m[7] + self.b * m[8]
        self.set(r, g, b)

    def hue_rotate(self, angle):
        a = angle / 180 * math.pi
        s, c = math.sin(a), math.cos(a)
        self.multiply([
            0.213 + c * 0.787 - s * 0.213, 0.715 - c * 0.715 - s * 0.715, 0.072 - c * 0.072 + s * 0.928,
            0.213 - c * 0.213 + s * 0.143, 0.715 + c * 0.285 + s * 0.140, 0.072 - c * 0.072 - s * 0.283,
            0.213 - c * 0.213 - s * 0.787, 0.715 - c * 0.715 + s * 0.715, 0.072 + c * 0.928 + s * 0.072,
        ])

    def sepia(self, v):
        self.multiply([
            0.393 + 0.607 * (1 - v), 0.769 - 0.769 * (1 - v), 0.189 - 0.189 * (1 - v),
            0.349 - 0.349 * (1 - v), 0.686 + 0.314 * (1 - v), 0.168 - 0.168 * (1 - v),
            0.272 - 0.272 * (1 - v), 0.534 - 0.534 * (1 - v), 0.131 + 0.869 * (1 - v),
        ])

    def saturate(self, v):
        self.multiply([
            0.213 + 0.787 * v, 0.715 - 0.715 * v, 0.072 - 0.072 * v,
            0.213 - 0.213 * v, 0.715 + 0.285 * v, 0.072 - 0.072 * v,
            0.213 - 0.213 * v, 0.715 - 0.715 * v, 0.072 + 0.928 * v,
        ])

    def brightness(self, v):
        self.set(self.r * v, self.g * v, self.b * v)

    def contrast(self, v):
        off = -0.5 * v + 0.5
        self.set(self.r * v + off * 255, self.g * v + off * 255, self.b * v + off * 255)

    def invert(self, v):
        self.set((v + self.r / 255 * (1 - 2 * v)) * 255,
                 (v + self.g / 255 * (1 - 2 * v)) * 255,
                 (v + self.b / 255 * (1 - 2 * v)) * 255)

    def hsl(self):
        r, g, b = self.r / 255, self.g / 255, self.b / 255
        mx, mn = max(r, g, b), min(r, g, b)
        h = s = 0.0
        lum = (mx + mn) / 2
        if mx != mn:
            d = mx - mn
            s = d / (2 - mx - mn) if lum > 0.5 else d / (mx + mn)
            if mx == r:
                h = (g - b) / d + (6 if g < b else 0)
            elif mx == g:
                h = (b - r) / d + 2
            else:
                h = (r - g) / d + 4
            h /= 6
        return h * 100, s * 100, lum * 100


def solve_filter(hexcolor, restarts=12):
    """The best of several seeded runs: one run lands within ~15 of a
    channel, a dozen within ~3, which is what upstream ships."""
    best = None
    for seed in range(restarts):
        chain, loss = _solve_filter(hexcolor, seed)
        if best is None or loss < best[1]:
            best = (chain, loss)
        if loss < 4:
            break
    return best


def _solve_filter(hexcolor, seed):
    target = Color(*(int(hexcolor.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)))
    th, ts, tl = target.hsl()
    rng = random.Random(f"{hexcolor}/{seed}")
    color = Color()

    def loss(f):
        color.set(0, 0, 0)
        color.invert(f[0] / 100)
        color.sepia(f[1] / 100)
        color.saturate(f[2] / 100)
        color.hue_rotate(f[3] * 3.6)
        color.brightness(f[4] / 100)
        color.contrast(f[5] / 100)
        h, s, lum = color.hsl()
        return (abs(color.r - target.r) + abs(color.g - target.g) + abs(color.b - target.b)
                + abs(h - th) + abs(s - ts) + abs(lum - tl))

    def fix(value, idx):
        mx = 100
        if idx == 2:
            mx = 7500
        elif idx in (4, 5):
            mx = 200
        if idx == 3:
            if value > mx:
                value %= mx
            elif value < 0:
                value = mx + value % mx
        elif value < 0:
            value = 0
        elif value > mx:
            value = mx
        return value

    def spsa(A, a, c, values, iters):
        values = list(values)
        best, best_loss = None, math.inf
        for k in range(iters):
            ck = c / (k + 1) ** (1 / 6)
            deltas = [1 if rng.random() > 0.5 else -1 for _ in range(6)]
            high = [v + ck * d for v, d in zip(values, deltas)]
            low = [v - ck * d for v, d in zip(values, deltas)]
            diff = loss(high) - loss(low)
            for i in range(6):
                g = diff / (2 * ck) * deltas[i]
                ak = a[i] / (A + k + 1)
                values[i] = fix(values[i] - ak * g, i)
            cur = loss(values)
            if cur < best_loss:
                best, best_loss = list(values), cur
        return best, best_loss

    wide, wide_loss = None, math.inf
    for _ in range(3):
        v, cur = spsa(5, [60, 180, 18000, 600, 1.2, 1.2], 15, [50, 20, 3750, 50, 100, 100], 1000)
        if cur < wide_loss:
            wide, wide_loss = v, cur
        if wide_loss < 25:
            break
    A1 = wide_loss + 1
    best, best_loss = spsa(wide_loss, [0.25 * A1, 0.25 * A1, A1, 0.25 * A1, 0.2 * A1, 0.2 * A1], 2, wide, 500)
    if wide_loss < best_loss:
        best, best_loss = wide, wide_loss
    f = [round(v) for v in best]
    return (f"brightness(0) saturate(100%) invert({f[0]}%) sepia({f[1]}%) saturate({f[2]}%) "
            f"hue-rotate({round(best[3] * 3.6)}deg) brightness({f[4]}%) contrast({f[5]}%)"), best_loss


def filters_for(colors):
    """{name: filter chain} for a {name: hex} map, through the cache."""
    cache = CACHE / "filters.json"
    try:
        known = json.loads(cache.read_text())
    except Exception:
        known = {}
    todo = sorted({h for h in colors.values() if h not in known})
    if todo:
        from concurrent.futures import ProcessPoolExecutor
        with ProcessPoolExecutor() as pool:
            for hexcolor, (chain, _) in zip(todo, pool.map(solve_filter, todo)):
                known[hexcolor] = chain
    out = {name: known[hexcolor] for name, hexcolor in colors.items()}
    if todo:
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps(known, indent=1, sort_keys=True))
    return out


# --- rendering -------------------------------------------------------------

FLAVOUR_LINE = r"^(\s*@{flavour}:\s*)\{{.*\}};\s*$"


def render_std(text, pal):
    """The lib with the theme's flavour carrying the theme's colours and
    filters, and the accent forced to the theme's accent in that flavour.
    The other flavours stay upstream's, so a page in light mode still gets
    latte."""
    flavour = pal.meta.get("flavour")
    if not flavour:
        sys.exit(f"userstyles: {pal.name}: palette has no meta.flavour")
    colors = {n: pal.colors[n] for n in NAMES}
    accent = pal.lookup("accent")
    line = re.compile(FLAVOUR_LINE.format(flavour=flavour), re.M)
    found = line.findall(text)
    if len(found) != 2:
        sys.exit(f"userstyles: std lib: expected a colour and a filter line for {flavour}")
    upstream = line.search(text).group(0)
    upstream_colors = dict(re.findall(r"@(\w+):\s*(#[0-9a-fA-F]{6})", upstream))
    if {k: v.lower() for k, v in upstream_colors.items()} == colors:
        filters = None  # upstream's filters already describe these colours
    else:
        filters = filters_for(colors | {"accent": accent})

    def sub(m):
        if filters is None:
            return m.group(0)
        if "#" in m.group(0):  # the colour line; the other is the filter line
            body = " ".join(f"@{n}: {colors[n]};" for n in NAMES)
        else:
            body = " ".join(f"@{n}: {filters[n]};" for n in NAMES)
        return f"{m.group(1)}{{ {body} }};"

    text = line.sub(sub, text)
    accent_filter = filters["accent"] if filters else "@catppuccin-filters[@@flavor][@@accentColor]"
    text, n1 = re.subn(r"^(\s*)@accent:\s*@catppuccin\[@@flavor\]\[@@accentColor\];",
                       rf"\1@accent: if((@flavor = {flavour}), {accent}, @catppuccin[@@flavor][@@accentColor]);",
                       text, flags=re.M)
    text, n2 = re.subn(r"^(\s*)@accent-filter:\s*@catppuccin-filters\[@@flavor\]\[@@accentColor\];",
                       rf"\1@accent-filter: if((@flavor = {flavour}), {accent_filter}, "
                       r"@catppuccin-filters[@@flavor][@@accentColor]);",
                       text, flags=re.M)
    if n1 != 1 or n2 != 1:
        sys.exit("userstyles: std lib: the accent lines moved; update render_std")
    return text


META = re.compile(r"/\*\s*==UserStyle==\s*\n(.*?)\n\s*==/UserStyle==\s*\*/", re.S)
VAR = re.compile(r"^@var\s+(\w+)\s+([\w-]+)\s+\"((?:[^\"\\]|\\.)*)\"\s+(.*)$")


def parse_var(line):
    """A @var line in the shape Stylus stores (what a backup carries)."""
    m = VAR.match(line.strip())
    if not m:
        return None
    kind, name, label, rest = m.groups()
    var = {"type": kind, "label": label, "name": name, "value": None}
    rest = rest.strip()
    if kind == "select":
        options, default = [], None
        for item in json.loads(rest):
            key, _, lbl = item.partition(":")
            if lbl.endswith("*"):
                lbl, default = lbl[:-1], key
            options.append({"name": key, "label": lbl or key, "value": key})
        var["default"] = default or options[0]["name"]
        var["options"] = options
    elif kind == "checkbox":
        var["default"] = rest
    elif kind in ("range", "number"):
        parts = json.loads(rest.replace("'", '"')) if rest.startswith("[") else [float(rest)]
        nums = [p for p in parts if not isinstance(p, str)]
        units = next((p for p in parts if isinstance(p, str)), None)
        var["default"] = nums[0]
        var["min"] = nums[1] if len(nums) > 1 else None
        var["max"] = nums[2] if len(nums) > 2 else None
        var["step"] = nums[3] if len(nums) > 3 else None
        var["units"] = units
    else:  # text, color
        var["default"] = json.loads(rest) if rest.startswith('"') else rest
    return var


def parse_meta(text):
    block = META.search(text)
    if not block:
        return None
    meta, vars_ = {}, {}
    for line in block.group(1).splitlines():
        line = line.strip()
        if line.startswith("@var "):
            var = parse_var(line)
            if var:
                vars_[var["name"]] = var
        elif line.startswith("@"):
            key, _, value = line[1:].partition(" ")
            meta[key] = value.strip()
    meta["vars"] = vars_
    return meta


def render_style(slug, text, lib, pal, update_url, accent_name):
    flavour = pal.meta["flavour"]
    if not STD_IMPORT.search(text):
        print(f"userstyles: {slug}: does not import the std lib, left as upstream", file=sys.stderr)
    else:
        text = STD_IMPORT.sub(lambda m: lib.rstrip("\n"), text, count=1)
    override = OVERRIDES / f"{slug}.less"
    if override.exists():
        text = text.rstrip("\n") + "\n\n" + pal.render(override.read_text())
    text = re.sub(r"^(@updateURL\s+).*$", lambda m: m.group(1) + update_url, text, count=1, flags=re.M)
    # The theme's flavour is the default dark flavour, so a fresh install
    # lands on it without a visit to the style's settings.
    def default_dark(m):
        opts = m.group(2).replace("*", "")
        opts = re.sub(rf'"{flavour}:([^"]*)"', rf'"{flavour}:\1*"', opts)
        return m.group(1) + opts
    text = re.sub(r'^(@var select darkFlavor "[^"]*" )(\[.*\])', default_dark, text, count=1, flags=re.M)
    meta = parse_meta(text)
    if not meta:
        print(f"userstyles: {slug}: no metadata block, skipped", file=sys.stderr)
        return None, None
    vars_ = meta["vars"]
    if "darkFlavor" in vars_:
        vars_["darkFlavor"]["value"] = flavour
    if "lightFlavor" in vars_:
        vars_["lightFlavor"]["value"] = "latte"
    if "accentColor" in vars_ and any(o["name"] == accent_name for o in vars_["accentColor"]["options"]):
        vars_["accentColor"]["value"] = accent_name
    entry = {
        "enabled": True,
        "name": meta.get("name", slug),
        "description": meta.get("description", ""),
        "author": meta.get("author", ""),
        "updateUrl": update_url,
        "usercssData": {k: meta[k] for k in ("name", "namespace", "homepageURL", "version", "updateURL",
                                             "supportURL", "description", "author", "license",
                                             "preprocessor") if k in meta} | {"vars": vars_},
        "sourceCode": text,
        "originalDigest": hashlib.sha1(text.encode()).hexdigest(),
    }
    return text, entry


def build(name, refresh=False, out=None):
    theme = theme_module()
    pal = theme.Palette(name)
    out = Path(out) if out else theme.DATA / name / "userstyles"
    out.mkdir(parents=True, exist_ok=True)
    lib = render_std(std(refresh), pal)
    (out / "std.less").write_text(lib)
    accent_name = pal.raw.get("semantic", {}).get("accent", "")
    bundle, kept = [], set()
    for slug in slugs():
        text = source(slug, refresh)
        if text is None:
            continue
        url = f"http://localhost:{PORT}/{theme.CURRENT.name}/userstyles/{slug}.user.less"
        rendered, entry = render_style(slug, text, lib, pal, url, accent_name)
        if rendered is None:
            continue
        (out / f"{slug}.user.less").write_text(rendered)
        kept.add(f"{slug}.user.less")
        bundle.append(entry)
    for stale in out.glob("*.user.less"):
        if stale.name not in kept:
            stale.unlink()
    (out / "import.json").write_text(json.dumps(bundle, indent=1, ensure_ascii=False))
    print(f"userstyles: {name}: {len(bundle)} styles -> {out}")


def serve():
    """~/.config/theme over the loopback interface, for Stylus's update
    checks. The directory is looked up per request, so `current` is
    followed wherever it points now."""
    import http.server
    theme = theme_module()
    root = str(theme.CONFIG)

    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=root, **kwargs)

        def end_headers(self):
            self.send_header("Cache-Control", "no-store")
            super().end_headers()

        def log_message(self, fmt, *args):
            pass

    with http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler) as httpd:
        print(f"userstyles: serving {root} on http://localhost:{PORT}/", flush=True)
        httpd.serve_forever()


def main(argv):
    cmd = argv[0] if argv else "list"
    args = argv[1:]
    if cmd == "build":
        names = [a for a in args if not a.startswith("--")]
        if not names:
            sys.exit(__doc__)
        out = None
        if "--out" in args:
            out = args[args.index("--out") + 1]
            names = [n for n in names if n != out]
        for name in names:
            build(name, refresh="--refresh" in args, out=out)
    elif cmd == "serve":
        serve()
    elif cmd == "fetch":
        std(refresh=True)
        for slug in slugs():
            source(slug, refresh=True)
        print(f"userstyles: fetched {len(slugs())} styles -> {CACHE}")
    elif cmd == "list":
        for slug in slugs():
            print(("* " if (CACHE / f"{slug}.user.less").exists() else "  ") + slug)
    elif cmd == "filter":
        for hexcolor in args:
            chain, loss = solve_filter(hexcolor)
            print(f"{hexcolor}: {chain}  (loss {loss:.1f})")
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
