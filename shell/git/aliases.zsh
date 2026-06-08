alias g="git"
ialias git="nocorrect git"

# Prefer g s – this is to catch typos
alias gs="git status"

lsnotrepos() {
  comm <(find . -maxdepth 1 -type d | sort) <(find . -name .git -maxdepth 2 | xargs dirname | sort) -3
}

# Fuzzy-select a git worktree and cd into it (command-line companion to the
# tmux popup switcher bound to prefix+W). A shell function rather than a script
# so the cd affects the calling shell.
gwt() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local selection
  selection=$(
    git worktree list |
      fzf --ansi --list-label ' Worktrees ' \
        --preview 'git -C {1} log --oneline --decorate --color -20'
  ) || return
  [[ -n "$selection" ]] && cd "${selection%% *}"
}
