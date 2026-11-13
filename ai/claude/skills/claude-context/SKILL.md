---
name: claude-context
description: Show which Claude Code context (claude-context.json) applies in the current directory, and set up a new or more specific one for it or a parent, choosing which claude.ai connectors and plugins to block and which MCP servers to add. Use when the user invokes /claude-context, sets up a new machine, asks why a connector or plugin is missing (or present) in a directory, or wants work and personal tools kept apart somewhere.
---

# Claude Code contexts

The `claude` wrapper adds the flags of the context that applies to the working
directory: the nearest `claude-context.json` walking up from it. Where there is
none, no context applies and every connector and plugin is available.
`~/claude-context.json` is the fallback under home. How it works, and what the
file may hold, is in `~/.dotfiles/ai/claude/README.md`. Read it if you haven't.

Context files are machine-local. Never write one into the dotfiles repository,
and never put connector or plugin names there either. Which tools are used at
work is private.

## 1. Say what applies

Run `claude_context` in the current directory and report:

- the file that applies, or that none does (and whether `CLAUDE_CONTEXT` is set
  in the environment, which overrides the directory)
- what it blocks (`settings.deniedMcpServers`), what plugins it turns off
  (`settings.enabledPlugins` set to `false`) and what servers it adds
  (`mcpServers`, names only: never print header values)
- that this session got the context of the directory it was *started* in, so
  a change shows up only in sessions started afterwards

If the user only wanted to know, stop here.

## 2. Ask where the context should sit

Offer, in one AskUserQuestion call (with the user's catch-all question last):

- the current directory
- the root of the git repository it is in, if that differs
- a meaningful parent (the folder holding several repositories of one
  organisation, say), if there is one
- `~`, the fallback for everything under home, if there is no
  `~/claude-context.json` yet

Name the path in each option, and say for each whether a file is already
there. Editing an existing file is a choice too.

A nearer file **replaces** the one above it; nothing merges. A new context
inside a work tree loses the work tree's blocks unless it repeats them. So
start from the contents of the file that applies now, unless the user wants a
clean slate.

If another existing context already says the right thing (a notes vault that
belongs to the same side as a work tree, say), offer to symlink that file
instead of writing a copy, so the two stay in step.

## 3. Take stock

- `claude mcp list` lists the connectors (`claude.ai <Name>`) and the servers
  plugins bring (`plugin:<plugin>:<server>`). It bypasses the wrapper, so it
  shows everything, blocked or not. Don't print the URLs back.
- `claude plugin list` lists the plugins. It repeats a plugin once per scope;
  list each `<plugin>@<marketplace>` once.

## 4. Choose

Ask with AskUserQuestion, multiSelect. The tool allows four options per
question and three real questions per call (plus the catch-all), so group the
connectors by four, in as many calls as it takes. Put the plugins in their own
question(s). Phrase each as "Which of these should be blocked in <path>?" and
say in each option's description whether it is blocked now. If it is clear
which side an account is on (the user said so, or another context blocks it),
recommend.

Then ask whether to add MCP servers of the directory's own (an HTTP server with
a URL, perhaps headers). Ask for the URL and header names. Have the user write
secret header values into the file themselves, or take them only if offered.

Connectors can be blocked but not added: a connector the account doesn't have
must be connected on claude.ai first. Each claude.ai connector holds one
connection, so a connector belongs to the side whose account it is connected
to, and should be blocked on the other side.

## 5. Write it

```json
{
  "name": "<work|personal|...>",
  "settings": {
    "deniedMcpServers": [{ "serverName": "claude.ai <Name>" }],
    "enabledPlugins": { "<plugin>@<marketplace>": false }
  },
  "mcpServers": {}
}
```

Leave out keys that would be empty. Then:

- `chmod 600` the file if it has `mcpServers` with headers
- if the file is in a git repository (other than one where the user wants it
  tracked), add `claude-context.json` to that repository's `.git/info/exclude`
- check it with `claude_context --args <dir>`, plus a directory below it,
  and, if a context sits above or below the new one, a directory there too, to
  show the split
- tell the user to restart any sessions running there
