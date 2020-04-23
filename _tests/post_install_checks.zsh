#!/usr/bin/env zsh

DIR=$(cd ${${(%):-%x}:A:h} && pwd -P)
source "$DIR"/../env

echo "Post install checks"
echo "doom version:"
doom version
[ "$?" = 0 ] || should_fail=true
echo
echo "zplug version:"
# Initialize zplug
_load shell/zsh/plugins.zsh
zplug --version
[ "$?" = 0 ] || should_fail=true
echo
echo "vscode version:"
code --version
[ "$?" = 0 ] || should_fail=true
echo

if [[ "$should_fail" = true ]]; then
  echo "There were problems, check the output above"
  exit 1
fi
