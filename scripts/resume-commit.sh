#!/usr/bin/env bash

ROOT_DIR=$(git rev-parse --show-toplevel)
git commit -em "$(sed '/^#/ d' ${ROOT_DIR}/.git/COMMIT_EDITMSG)"
