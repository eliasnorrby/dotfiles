# The OS

`~/os` is the entrypoint to Elias's agentic OS: one place to start a session
that works *through* the OS (on a task, on a note) or *on* it (its tooling,
the dotfiles, the workstation). There is one OS for work and personal life;
the line between them runs through the data, not the tooling. This directory
holds no content of its own. Sessions started here can reach the vaults, the
dotfiles and the repositories (`.claude/settings.json`).

**How the OS works today** is described in the personal vault, on the hub
`~/vaults/personal/wiki/topics/Agentic OS.md` and the pages it lists. Read it
before changing anything about the OS, and keep it current when you do: it is
the as-built description, and the roadmap and decisions hang under it.

## Where things are

- **Code**: the dotfiles (`~/.dotfiles`, read its `AGENTS.md` before editing).
  The OS's own topic is `ai/os` (this file, `wiki_checkpoint`, the wiki schema,
  the sweeper and usage timers); work items are `dev/wk`; Claude Code's
  configuration and general skills are `ai/claude`; Obsidian and `~/vaults`
  are `tools/obsidian`.
- **Memory**: the Obsidian vaults under `~/vaults`, each an LLM-maintained
  wiki with its own `CLAUDE.md`. Which vault a piece of work belongs to
  follows from its taskwarrior project: `wk config get projects.<project>.vault`,
  default `wk config get defaults.vault`. The work vault holds what belongs to
  the employer; the personal vault holds everything else, the OS's own
  documentation included.
- **Work**: repositories, listed in wk's configuration (`wk config get repos`).
- **Tasks**: taskwarrior, through `wk`. Work on the OS itself is project `os`
  (its tasks open here, no worktree); workstation configuration is
  `dotfiles`; employer work has its own project.

## Where things go

- **A thought for later**: a jot in the right vault's `inbox/`, one
  timestamped file (`YYYY-MM-DD HHMM.md`). The vault's drain turns it into a
  task, a page or both.
- **Something to do on the OS**: a task in project `os`, with its note in the
  personal vault's `tasks/` (`wk` creates both).
- **Knowledge**: the vault's wiki, by its schema. Checkpoint with the
  `wiki-checkpoint` skill as usual.
- **A skill**: by what it knows. A procedure useful anywhere Elias works goes
  in the dotfiles (`ai/claude/skills/`, or the topic it belongs to, linked one
  by one into `~/.claude/skills/`); facts it needs about an employer come from
  config or the wiki, not the skill text. A skill about one repository's code,
  useful to its team, goes in that repository's `.claude/skills/` through a
  PR; a draft lives uncommitted on a branch there until it is shared. Nothing
  lives only in a home directory: if it is neither, it is a wiki page.
