# claude

Claude Code's user settings, statusline, skills, agents and helper scripts,
plus the contexts that keep work and personal tools apart.

## Contexts

One claude.ai subscription serves both work and personal life. Its connectors
(Gmail, Calendar, Notion, ...) come with the account, so every Claude Code
session sees all of them, and the account holds one connection per connector.
Contexts decide, by directory, which of those a session gets, and add the
servers that only belong to one side.

`claude.sh` is linked into `$XDG_BIN_HOME` as `claude`, ahead of the real
binary on `PATH`, so every launcher goes through it. It asks
`claude_context --args` for flags, adds them, and runs the next `claude` on
`PATH`. Subcommands (`claude mcp`, `claude auth`, ...) pass through untouched.

A tree declares its context with a `claude-context.json` at its root. The
wrapper finds it by walking up from the working directory, the way Claude Code
finds `.mcp.json`. Where no tree declares one, no context applies and the
session sees everything.

```json
{
  "name": "work",
  "settings": {
    "deniedMcpServers": [{ "serverName": "claude.ai Gmail" }]
  },
  "mcpServers": {
    "notion": { "type": "http", "url": "https://mcp.notion.com/mcp" }
  }
}
```

- `settings` is passed as `--settings`. In practice: `deniedMcpServers` to
  block connectors by their display name (`claude.ai <Name>`, as `claude mcp
  list` prints it), and `enabledPlugins` to turn plugins off.
- `mcpServers` is passed as `--mcp-config` by path, so the servers need no
  approval and a header with an API key stays out of the process list. Keep
  such a file `chmod 600`.
- `name` is for people.

Context files are machine-local and not in this repository: which tools one
side of life uses is nobody else's business, and each machine has its own
connections anyway. A `~/claude-context.json` is the fallback for everything
under home, so that is where the personal one goes; a work tree gets its own,
which wins because it is nearer. To give a directory outside the tree the
same context (a vault, say), symlink the file there; in a git repository,
list it in `.git/info/exclude`.

The `claude-context` skill sets one up: it says what applies where you invoke
it, asks where the new context should sit, and walks through which
connectors, plugins and servers it should block or add.

### Asking what applies

```sh
claude_context              # the file for this directory, and what is in it
claude_context ~/some/dir   # for another directory
claude_context --args       # the flags the wrapper would add
```

`claude mcp list` doesn't know about contexts (subcommands bypass the wrapper).
Inside a session, `/mcp` shows what that session actually got.

### Opting out

`CLAUDE_CONTEXT=none` runs Claude without a context; `CLAUDE_CONTEXT=<file>`
picks one regardless of the directory. Headless jobs that need a specific set
of tools set it (focus's break brief needs the Slack plugin, which the
personal context turns off).
