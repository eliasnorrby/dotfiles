#!/usr/bin/env bash

SECONDS=0
echo "Checking to see if all listed npm/pip packages are available"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
echo "DIR: $DIR"
. $DIR/_helpers.sh

npm_packages=$(get_complete_list "npm_packages")
pip_packages=$(get_complete_list "pip_packages")

echo "npm version:"
npm --version
echo
echo "pip version:"
pip3 --version
echo

echo "> Checking npm packages..."
for package in $npm_packages; do
  printf "${package}... "
  npm info $package > /dev/null
  [ "$?" == 0 ] && printf " OK \n" || should_fail=true
done

echo "> Checking pip packages..."
for package in $pip_packages; do
  printf "${package}... "
  pip3 search $package > /dev/null
  [ "$?" == 0 ] && printf " OK \n" || should_fail=true
done

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo "Check completed in $ELAPSED"

if [ "$should_fail" == true ] ; then
  echo "There were problems, check the output above"
  exit 1
fi


