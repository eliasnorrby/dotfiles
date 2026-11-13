#!/usr/bin/env python3
"""theme: render and switch desktop themes.

A theme is a palette (themes/<name>/palette.toml). Templates (templates/*)
are rendered against it into $XDG_DATA_HOME/theme/<name>/, together with
the theme's wallpaper. The only local state is the symlink
$XDG_CONFIG_HOME/theme/current, which points at one rendered theme; app
configs reference files under it.

    theme list                 the themes that exist, and which is current
    theme build [NAME...]      render (all themes by default)
    theme set NAME [--no-reload]
                               build, relink current, reload running apps
    theme cycle                the next theme in the list
    theme current              the current theme's name
    theme get TOKEN [NAME]     one resolved value, for scripts
    theme reload               re-run the reload hooks for the current theme

Template syntax: {{token}} gives #rrggbb; {{token.hex}} drops the hash,
{{token.rgb}} is "r, g, b", {{token.argb}} is 0xffrrggbb. Tokens come from
the palette's [semantic] table, then [colors]; {{ansi.NAME}}, {{chrome.NAME}}
and {{meta.NAME}} read those tables. Standard library only.
"""

import json
import os
import time
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

HERE = Path(__file__).resolve().parent
THEMES = HERE / "themes"
TEMPLATES = HERE / "templates"
DATA = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "theme"
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "theme"
CURRENT = CONFIG / "current"

# Consumers that cannot include a file get a symlink to the rendered one,
# at a fixed place under their own config dir. Made on `theme set` when the
# parent dir exists, so the same list serves arch and macOS.
EXPORTS = {
    "hyprtoolkit.conf": ["~/.config/hypr/hyprtoolkit.conf"],
    "mako.ini": ["~/.config/mako/theme"],
    "rofi.rasi": ["~/.config/rofi/system.rasi"],
    "btop.theme": ["~/.config/btop/themes/system.theme"],
    "k9s.yaml": ["~/.config/k9s/skins/system.yaml"],
    "yazi.toml": ["~/.config/yazi/theme.toml", "~/.config/yazi-picker/theme.toml"],
}

DEBUG = os.environ.get("THEME_DEBUG")


def timed(label, fn, *args, **kwargs):
    start = time.time()
    result = fn(*args, **kwargs)
    if DEBUG:
        print(f"theme: {label}: {time.time() - start:.2f}s", file=sys.stderr)
    return result


TOKEN = re.compile(r"\{\{\s*([a-zA-Z_][\w.]*?)(?:\.(hex|rgb|argb))?\s*\}\}")
HEX = re.compile(r"^#?([0-9a-fA-F]{6})$")


class Palette:
    def __init__(self, name):
        self.name = name
        path = THEMES / name / "palette.toml"
        if not path.exists():
            sys.exit(f"theme: no such theme: {name}")
        self.raw = tomllib.loads(path.read_text())
        self.colors = {k: self._hex(v, k) for k, v in self.raw.get("colors", {}).items()}
        self.semantic = {}
        for k, v in self.raw.get("semantic", {}).items():
            self.semantic[k] = self.colors[v] if v in self.colors else self._hex(v, k)
        self.ansi = {}
        for k, v in self.raw.get("ansi", {}).items():
            self.ansi[k] = self.lookup(v) if not HEX.match(str(v)) else self._hex(v, k)
        self.chrome = self.raw.get("chrome", {})
        self.meta = self.raw.get("meta", {})
        self.wallpaper = self.raw.get("wallpaper", {})

    @staticmethod
    def _hex(value, key):
        m = HEX.match(str(value))
        if not m:
            sys.exit(f"theme: {key}: not a colour: {value!r}")
        return "#" + m.group(1).lower()

    def lookup(self, name):
        if name in self.semantic:
            return self.semantic[name]
        if name in self.colors:
            return self.colors[name]
        ns, _, key = name.partition(".")
        table = {"ansi": self.ansi, "chrome": self.chrome, "meta": self.meta}.get(ns)
        if table is None or key not in table:
            sys.exit(f"theme: {self.name}: unknown token {name!r}")
        return table[key]

    def render(self, text):
        def sub(m):
            value = self.lookup(m.group(1))
            form = m.group(2)
            if form is None or not isinstance(value, str) or not HEX.match(value):
                return str(value)
            h = value.lstrip("#")
            if form == "hex":
                return h
            if form == "argb":
                return "0xff" + h
            if form == "rgb":
                return ", ".join(str(int(h[i:i + 2], 16)) for i in (0, 2, 4))
            return value
        return TOKEN.sub(sub, text)


def themes():
    return sorted(p.name for p in THEMES.iterdir() if (p / "palette.toml").exists())


def current():
    if CURRENT.is_symlink():
        return Path(os.readlink(CURRENT)).name
    return None


def screen_size():
    try:
        out = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True, timeout=3)
        mons = json.loads(out.stdout)
        if mons:
            return mons[0]["width"], mons[0]["height"]
    except Exception:
        pass
    return 3840, 2160


def build_wallpaper(pal, out):
    spec = pal.wallpaper
    target = out / "wallpaper"
    if "script" in spec and not shutil.which("hyprpaper"):
        # Nothing here would show it, and rendering needs uv and numpy.
        return
    if "script" in spec:
        # Rendering is slow and goes through uv, so keep the last render
        # unless the script or the palette changed since.
        png = target.with_suffix(".png")
        script = HERE / spec["script"]
        palette_file = THEMES / pal.name / "palette.toml"
        if png.exists() and png.stat().st_mtime > max(script.stat().st_mtime, palette_file.stat().st_mtime):
            return
    if "file" in spec:
        for stale in out.glob("wallpaper*"):
            stale.unlink()
        src = Path(os.path.expanduser(spec["file"]))
        if not src.exists():
            print(f"theme: {pal.name}: wallpaper file missing: {src}", file=sys.stderr)
            return
        head = src.open("rb").read(4)
        ext = {b"\x89PNG": ".png", b"\xff\xd8\xff\xe0": ".jpg", b"\xff\xd8\xff\xe1": ".jpg",
               b"\xff\xd8\xff\xdb": ".jpg"}.get(head, src.suffix or ".img")
        target = target.with_suffix(ext)
        target.symlink_to(src)
    elif "script" in spec:
        script = HERE / spec["script"]
        target = target.with_suffix(".png")
        fresh = out / "wallpaper.rendering.png"
        w, h = screen_size()
        env = dict(os.environ, THEME_PALETTE=str(THEMES / pal.name / "palette.toml"))
        args = [str(script), str(w), str(h), str(fresh)]
        if spec.get("uv"):
            # --no-project: uv would otherwise sync whatever project the caller
            # happens to be in. --offline first: uv resolves against PyPI on
            # every run otherwise, and a slow PyPI stalls the switch.
            base = ["uv", "run", "--quiet", "--no-project", "--with", spec["uv"]]
            done = subprocess.run(base + ["--offline"] + args, env=env, cwd=HERE)
            if done.returncode != 0:
                subprocess.run(base + args, check=True, env=env, cwd=HERE)
        else:
            subprocess.run(["python3"] + args, check=True, env=env, cwd=HERE)
        for stale in out.glob("wallpaper*"):
            if stale != fresh:
                stale.unlink()
        fresh.replace(target)
    else:
        return
    # A fixed name for configs to point at, whatever the format.
    link = out / "wallpaper"
    link.symlink_to(target.name)


def yazi_icons(pal):
    """Yazi's default icon rules, recoloured. The defaults are embedded in
    the binary, so fetch the preset for the installed version (cached), and
    fall back to the copy under presets/ when offline."""
    import urllib.request
    cache = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "theme"
    cache.mkdir(parents=True, exist_ok=True)
    preset = HERE / "presets" / "yazi-theme-dark.toml"
    try:
        ver = subprocess.run(["yazi", "--version"], capture_output=True, text=True, timeout=5).stdout
        ver = re.search(r"Version:\s*([\d.]+)", ver).group(1)
        cached = cache / f"yazi-theme-dark-{ver}.toml"
        if not cached.exists():
            url = f"https://raw.githubusercontent.com/sxyazi/yazi/v{ver}/yazi-config/preset/theme-dark.toml"
            with urllib.request.urlopen(url, timeout=10) as r:
                cached.write_bytes(r.read())
        preset = cached
    except Exception as e:
        print(f"theme: yazi preset: using the committed copy ({e})", file=sys.stderr)
    text = preset.read_text()
    icon = text[text.index("[icon]"):]
    colours = {"dir": pal.lookup("icon_dir"), "file": pal.lookup("icon_file"),
               "exec": pal.lookup("accent"), "broken": pal.lookup("alert")}
    out, section = [], None
    for line in icon.splitlines():
        m = re.match(r"^(globs|dirs|files|exts|conds)\s*=", line)
        if m:
            section = m.group(1)
        if "fg = " in line:
            c = colours["dir"] if section == "dirs" else colours["file"]
            if section == "conds":
                if re.search(r'if = "(dir|dummy|dir & hovered)"', line):
                    c = colours["dir"]
                elif re.search(r'if = "(orphan|broken)"', line):
                    c = colours["broken"]
                elif re.search(r'if = "exec"', line):
                    c = colours["exec"]
            line = re.sub(r'fg = "[^"]*"', f'fg = "{c}"', line)
        out.append(line)
    return ("# Icons: yazi's default rules for the installed version, with the colours\n"
            "# flattened. Directories, files, executables, broken links.\n" + "\n".join(out).rstrip() + "\n")


def build(name):
    pal = Palette(name)
    out = DATA / name
    out.mkdir(parents=True, exist_ok=True)
    def templates():
        for tmpl in sorted(TEMPLATES.iterdir()):
            if tmpl.name.startswith("."):
                continue
            text = tmpl.read_text()
            if "{{yazi.icons}}" in text:
                text = text.replace("{{yazi.icons}}", yazi_icons(pal))
            (out / tmpl.name).write_text(pal.render(text))
    timed("templates", templates)
    timed("wallpaper", build_wallpaper, pal, out)
    if shutil.which("userstyles"):
        # The browser userstyles (tools/stylus); nothing here is worse off
        # when it fails, so it may.
        timed("userstyles", subprocess.run, ["userstyles", "build", name])
    print(f"theme: built {name} -> {out}")
    return out


def reload():
    """Tell running apps to pick the new files up. Each hook is skipped when
    its app is not running or its tool is not installed, so the same list
    serves arch and macOS. The wallpaper goes first: it is the largest
    surface, and everything else changing while it lags is what the eye
    notices."""
    def running(proc):
        return subprocess.run(["pgrep", "-x", proc], capture_output=True).returncode == 0

    def have(tool):
        return shutil.which(tool) is not None

    if have("hyprctl") and running("hyprpaper"):
        # hyprpaper 0.8 takes `wallpaper MONITOR,path` and silently ignores
        # the form without a monitor, so address each monitor by name.
        wallpaper = (CURRENT / "wallpaper").resolve()
        ok = False
        try:
            mons = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True,
                                             text=True, timeout=3).stdout)
            for mon in mons:
                done = subprocess.run(["hyprctl", "hyprpaper", "wallpaper", f"{mon['name']},{wallpaper}"],
                                      capture_output=True, text=True, timeout=5)
                ok = ok or (done.returncode == 0 and "error" not in done.stdout)
        except Exception:
            ok = False
        if not ok:
            subprocess.run(["pkill", "-x", "hyprpaper"])
            subprocess.run(["hyprctl", "dispatch", "exec", "hyprpaper"], capture_output=True)
    if running("kitty"):
        subprocess.run(["pkill", "-SIGUSR1", "-x", "kitty"])
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
    procs = []
    for sock in list(runtime.glob("nvim.*.0")) + list(Path("/tmp").glob("nvim*/0")):
        procs.append((sock, subprocess.Popen(
            ["nvim", "--server", str(sock), "--remote-send",
             "<Cmd>lua package.loaded['core.theme'] = nil require('core.theme').apply()<CR>"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)))
    for sock, proc in procs:
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
            print(f"theme: neovim at {sock.name} did not answer", file=sys.stderr)
    if have("hyprctl") and running("Hyprland"):
        subprocess.run(["hyprctl", "reload"], capture_output=True)
    if running("waybar"):
        subprocess.run(["pkill", "-SIGUSR2", "-x", "waybar"])
    if running("swaync") and have("swaync-client"):
        subprocess.run(["swaync-client", "--reload-css"], capture_output=True)
    if running("mako") and have("makoctl"):
        subprocess.run(["makoctl", "reload"], capture_output=True)


def export():
    """Point each consumer's fixed path at current/<file>, where the
    consumer is configured here at all (its config dir exists). What the
    old setup left behind is migrated: a parent that is itself a symlink
    (btop's themes and k9s' skins dirs used to link into the repo) becomes
    a real directory, and a real file in the way (yazi's downloaded theme)
    is kept beside the link as <name>.pre-theme."""
    for rendered, dests in EXPORTS.items():
        for dest in dests:
            dest = Path(os.path.expanduser(dest))
            parent = dest.parent
            if parent.is_symlink():
                if not parent.parent.exists():
                    continue
                parent.unlink()
                parent.mkdir()
            elif not parent.exists():
                if parent.parent.exists() and parent.name in ("themes", "skins"):
                    parent.mkdir()
                else:
                    continue
            if dest.exists() and not dest.is_symlink():
                keep = dest.with_name(dest.name + ".pre-theme")
                dest.replace(keep)
                print(f"theme: kept the old {dest.name} as {keep.name}", file=sys.stderr)
            if dest.is_symlink():
                dest.unlink()
            dest.symlink_to(CURRENT / rendered)


def set_theme(name, do_reload=True):
    out = build(name)
    CONFIG.mkdir(parents=True, exist_ok=True)
    tmp = CONFIG / ".current.tmp"
    if tmp.is_symlink() or tmp.exists():
        tmp.unlink()
    tmp.symlink_to(out)
    tmp.replace(CURRENT)
    print(f"theme: current -> {name}")
    export()
    # Claude Code watches ~/.claude/themes for writes; a symlink that
    # silently changes target is not one, so copy the rendered file in.
    claude_themes = Path.home() / ".claude/themes"
    if not claude_themes.is_symlink():
        claude_themes.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(out / "claude.json", claude_themes / "system.json")
    if do_reload:
        timed("reload", reload)


def cycle():
    names = themes()
    if not names:
        sys.exit("theme: no themes")
    cur = current()
    nxt = names[(names.index(cur) + 1) % len(names)] if cur in names else names[0]
    set_theme(nxt)


def main(argv):
    cmd = argv[0] if argv else "list"
    args = argv[1:]
    if cmd == "list":
        cur = current()
        for name in themes():
            print(("* " if name == cur else "  ") + name)
    elif cmd == "build":
        for name in args or themes():
            build(name)
    elif cmd == "set":
        if not args:
            sys.exit(__doc__)
        set_theme(args[0], do_reload="--no-reload" not in args)
    elif cmd == "cycle":
        cycle()
    elif cmd == "current":
        print(current() or "")
    elif cmd == "get":
        if not args:
            sys.exit(__doc__)
        name = args[1] if len(args) > 1 else current()
        if not name:
            sys.exit("theme: no current theme")
        print(Palette(name).lookup(args[0]))
    elif cmd == "reload":
        if not current():
            sys.exit("theme: no current theme")
        reload()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
