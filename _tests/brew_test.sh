#!/usr/bin/env bash

SECONDS=0
echo "Checking to see if all listed formulas and casks are available"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
. $DIR/_helpers.sh

brew_taps=$(get_complete_list "brew_taps")
brew_casks=$(get_complete_list "brew_casks")
brew_formulae=$(get_complete_list "brew_formulas")

echo "> Tapping taps..."
if ! [ -z "$brew_taps" ] ; then
  echo "$brew_taps" | tr ' ' '\n'
  echo
  for tap in ${brew_taps[@]}; do
    printf "${tap}... "
    brew tap $tap > /dev/null
    [ $? -eq 0 ] && printf " OK \n" || should_fail=true
  done
else
  echo "None found"
fi
echo

echo "> Checking brew formulae..."
# for formula in ${brew_formulae[@]}; do
#   printf "Checking ${formula}..."
#   brew info $formula > /dev/null
#   # echo "works" > /dev/null
#   [ $? -eq 0 ] && printf " OK \n" || should_fail=true
# done

if ! [ -z "$brew_formulae" ] ; then
  echo "$brew_formulae" | tr ' ' '\n'
  echo
  brew info $brew_formulae > /dev/null
  [ $? -eq 0 ] && printf " OK \n" || should_fail=true
else
  echo "None found"
fi
echo

echo "> Checking brew casks.."
# for cask in ${brew_casks[@]}; do
#   printf "Checking ${cask}..."
#   brew cask info $cask > /dev/null
#   # echo "broken" && false > /dev/null
#   [ $? -eq 0 ] && printf " OK \n" || should_fail=true
# done

if ! [ -z "$brew_casks" ] ; then
  echo "$brew_casks" | tr ' ' '\n'
  echo
  brew info --cask $brew_casks > /dev/null
  [ $? -eq 0 ] && printf " OK \n" || should_fail=true
else
  echo "None found"
fi
echo

ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo "Check completed in $ELAPSED"

if [[ "$should_fail" == true ]] ; then
  echo "There were problems, check brew's output above"
  exit 1
fi

