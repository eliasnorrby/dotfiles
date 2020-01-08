#!/usr/bin/env zsh

# echo $DOTFILES
# source $(cd ${${(%):-%x}:A:h} && pwd -P)/env
# echo "Hello world"
# ANSIBLE_STDOUT_CALLBACK=dense ansible-playbook playbook.yml "$@"
ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook playbook.yml "$@"
