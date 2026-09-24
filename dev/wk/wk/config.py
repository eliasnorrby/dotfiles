"""Configuration: everything specific to a company, a tracker or a machine.

Read from $WK_CONFIG, else $XDG_CONFIG_HOME/wk/config.toml. The file is
machine-local and not managed by the dotfiles; config.example.toml documents
it. Nothing here may assume a shell environment: the TUI is launched from a
.desktop entry and the sync timer from systemd, neither of which exports XDG_*.
"""

import os

from .errors import NotFound, WkError

DEFAULTS = {
    "defaults": {
        "project": "inbox",
        "vault": "personal",
        "vaults_dir": "~/vaults",
        "tracker": "linear",
    },
    "notes": {
        "subdirs": ["wiki/tasks", "tasks"],
        "archive": "archive",
        "flag": "󰎞",
    },
    "teams": {},
    "projects": {},
    "repos": {},
}


def xdg(kind):
    """The wk directory under an XDG base: config, cache or state."""
    fallback = {"config": "~/.config", "cache": "~/.cache", "state": "~/.local/state"}
    base = os.environ.get(f"XDG_{kind.upper()}_HOME") or os.path.expanduser(fallback[kind])
    return os.path.join(base, "wk")


def config_path():
    return os.environ.get("WK_CONFIG") or os.path.join(xdg("config"), "config.toml")


def _merge(base, over):
    out = dict(base)
    for key, value in over.items():
        if isinstance(value, dict) and isinstance(out.get(key), dict):
            out[key] = _merge(out[key], value)
        else:
            out[key] = value
    return out


class Config:
    def __init__(self, data=None, path=None):
        self.data = _merge(DEFAULTS, data or {})
        self.path = path

    @classmethod
    def load(cls, path=None):
        import tomllib

        path = path or config_path()
        try:
            with open(path, "rb") as handle:
                data = tomllib.load(handle)
        except FileNotFoundError:
            data = {}
        except tomllib.TOMLDecodeError as err:
            raise WkError(f"{path}: {err}") from err
        return cls(data, path)

    def get(self, dotted):
        """Look up `a.b.c`. Keys may themselves contain dots ("owner/repo" is
        fine, but so is a quoted "a.b"), so the longest matching key wins."""
        node = self.data
        parts = dotted.split(".")
        while parts:
            if not isinstance(node, dict):
                raise NotFound(f"no such config key: {dotted}")
            for end in range(len(parts), 0, -1):
                key = ".".join(parts[:end])
                if key in node:
                    node = node[key]
                    parts = parts[end:]
                    break
            else:
                raise NotFound(f"no such config key: {dotted}")
        return node

    @property
    def vaults_dir(self):
        return os.path.expanduser(self.data["defaults"]["vaults_dir"])

    @property
    def note_subdirs(self):
        return list(self.data["notes"]["subdirs"])

    @property
    def archive_subdir(self):
        return self.data["notes"]["archive"]

    @property
    def note_flag(self):
        return self.data["notes"]["flag"]

    def vault_for_project(self, project):
        """Matched on the project root, so `work.backend` maps via `work`."""
        root = (project or "").split(".")[0]
        entry = self.data["projects"].get(root, {})
        return entry.get("vault") or self.data["defaults"]["vault"]

    def team(self, issue_key):
        prefix = issue_key.rsplit("-", 1)[0].upper()
        teams = {name.upper(): value for name, value in self.data["teams"].items()}
        return teams.get(prefix, {})

    def project_for_issue(self, issue_key):
        return self.team(issue_key).get("project") or self.data["defaults"]["project"]

    def tracker_for_issue(self, issue_key):
        return self.team(issue_key).get("tracker") or self.data["defaults"]["tracker"]

    def merge_flags(self, repo):
        """`gh pr merge` flags for the repository's merge strategy: its own
        `merge`, else the default. Empty leaves the choice to gh, which asks."""
        entry = self.data["repos"].get(repo or "", {})
        method = entry.get("merge", self.data["defaults"].get("merge")) or ""
        if method not in ("", "merge", "squash", "rebase"):
            raise WkError(f"merge = {method!r} in {self.path}: use merge, squash or rebase")
        return [f"--{method}"] if method else []

    def project_for_repo(self, repo):
        entry = self.data["repos"].get(repo or "", {})
        return entry.get("project") or self.data["defaults"]["project"]

    def project_for_directory(self, directory, repo=None):
        """The project work in DIRECTORY belongs to: its repository's, else
        that of the project whose `dir` holds it (the deepest), else the
        default. So a session in ~/os lands in `os` without being told."""
        entry = self.data["repos"].get(repo or "", {})
        if entry.get("project"):
            return entry["project"]
        directory = os.path.realpath(directory)
        found, depth = None, -1
        for name, project in self.data["projects"].items():
            root = project.get("dir")
            if not root:
                continue
            root = os.path.realpath(os.path.expanduser(root))
            if (directory == root or directory.startswith(root + os.sep)) and len(root) > depth:
                found, depth = name, len(root)
        return found or self.data["defaults"]["project"]

    def project_names(self):
        """Every project the configuration knows of, for a session choosing one."""
        names = {self.data["defaults"]["project"], *self.data["projects"]}
        names.update(entry["project"] for entry in self.data["repos"].values() if entry.get("project"))
        names.update(team["project"] for team in self.data["teams"].values() if team.get("project"))
        return sorted(names)
