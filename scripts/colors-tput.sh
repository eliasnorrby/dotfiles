#!/usr/bin/env bash

# Source this file to use its functions

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
LIGHT_GRAY=$(tput setaf 7)

DARK_GRAY=$(tput setaf 8)
LIGHT_RED=$(tput setaf 9)
LIGHT_GREEN=$(tput setaf 10)
YELLOW=$(tput setaf 11)
LIGHT_BLUE=$(tput setaf 12)
LIGHT_PURPLE=$(tput setaf 13)
LIGHT_CYAN=$(tput setaf 14)
WHITE=$(tput setaf 15)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_ORANGE=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_PURPLE=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_LIGHT_GRAY=$(tput setab 7)

BG_DARK_GRAY=$(tput setab 8)
BG_LIGHT_RED=$(tput setab 9)
BG_LIGHT_GREEN=$(tput setab 10)
BG_YELLOW=$(tput setab 11)
BG_LIGHT_BLUE=$(tput setab 12)
BG_LIGHT_PURPLE=$(tput setab 13)
BG_LIGHT_CYAN=$(tput setab 14)
BG_WHITE=$(tput setab 15)

BOLD=$(tput bold)

NC=$(tput sgr 0) # No Color

function echo-info  { printf "\r${BG_BLUE}${BLACK}${BOLD} INFO ${NC} %s\n" "$*"; }
function echo-skip  { printf "\r${BG_DARK_GRAY}${WHITE} SKIP ${NC} %s\n" "$*"; }
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
