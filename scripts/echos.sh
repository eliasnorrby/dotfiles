#!/usr/bin/env bash

# Source this file to use its functions

DIR=$(dirname $([ -L "$0" ] && readlink -f "$0" || echo $0))
[ -f $DIR/colors.sh ] && . $DIR/colors.sh || (echo "Could not source 'colors', aborting" && exit 1)

function echo-info  { printf "\r${BG_BLUE}${BLACK}${BOLD} INFO ${NC} %s\n" "$*"; }
function echo-skip  { printf "\r${BG_DARK_GRAY}${WHITE} SKIP ${NC} %s\n" "$*"; }
function echo-warn  { printf "\r${BG_ORANGE}${BLACK}${BOLD} WARN ${NC} %s\n" "$*"; }
function echo-ok  { printf "\r${BG_GREEN}${BLACK}${BOLD}  OK  ${NC} %s\n" "$*"; }
function echo-fail  { printf "\r${BG_RED}${BLACK}${BOLD} FAIL ${NC} %s\n" "$*"; }

# function echo-info  { printf "\r\033[2K\033[0;34m[ .. ]\033[0m %s\n" "$*"; }
# function echo-skip  { printf "\r\033[2K\033[38;05;240m[SKIP]\033[0m %s\n" "$*"; }
# function echo-ok    { printf "\r\033[2K\033[0;32m[ OK ]\033[0m %s\n" "$*"; }
# function echo-fail  { printf "\r\033[2K\033[0;31m[FAIL]\033[0m %s\n" "$*"; }

# Test it!
# echo-info This is some info
# echo-info This is some info
# echo-skip Skipping this one okay
# echo-ok All is well and all
# echo-fail We are all going to die
