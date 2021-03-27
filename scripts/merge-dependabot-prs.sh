#!/usr/bin/env bash

# Call in a repo with dependabot configured. Tries to merge all outstanding
# dependabot updates into a single branch.

git checkout -b dependabot-updates

git remote prune origin

for branch in $(git branch -r | grep 'dependabot/npm_and_yarn'); do
  if ! git merge --no-edit "$branch"; then
    git merge --abort
    echo "Could not merge $branch"
  fi
done

git rebase master
