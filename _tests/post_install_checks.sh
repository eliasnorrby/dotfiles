#!/usr/bin/env bash

echo "Post install checks"
echo "doom version:"
doom version
[ "$?" = 0 ] || should_fail=true
echo
echo "zplug version:"
zplug --version
[ "$?" = 0 ] || should_fail=true
echo
echo "vscode version:"
code --version
[ "$?" = 0 ] || should_fail=true
echo

if [ "$should_fail" = true ] ; then
  echo "There were problems, check the output above"
  exit 1
fi
