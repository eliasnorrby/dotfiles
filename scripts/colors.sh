#!/usr/bin/env bash

NC=$(tput sgr 0) # No Color

for i in {0..15}; do
  color=$(tput setaf $i)
  echo "${color}█████${NC} ${i}"
done
