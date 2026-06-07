alias g="git"
ialias git="nocorrect git"

# Prefer g s – this is to catch typos
alias gs="git status"

lsnotrepos() {
  comm <(find . -maxdepth 1 -type d | sort) <(find . -name .git -maxdepth 2 | xargs dirname | sort) -3
}
