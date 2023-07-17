alias g="git"
ialias git="nocorrect git"

alias grvw="gh repo view -w"
alias abp="auto_branch_pruner"

lsnotrepos() {
  comm <(find . -maxdepth 1 -type d | sort) <(find . -name .git -maxdepth 2 | xargs dirname | sort) -3
}
