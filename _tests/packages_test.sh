#!/usr/bin/env bash

SECONDS=0
echo "Checking to see if all listed npm packages are available"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
echo "DIR: $DIR"
. $DIR/_helpers.sh

npm_packages=$(get_complete_list "npm_packages")

echo "npm version:"
npm --version
echo

echo "> Checking npm packages..."
for package in $npm_packages; do
  printf "${package}... "
  npm info $package > /dev/null
  [ $? -eq 0 ] && printf " OK \n" || should_fail=true
done

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo "Check completed in $ELAPSED"

if [[ "$should_fail" == true ]] ; then
  echo "There were problems, check the output above"
  exit 1
fi
