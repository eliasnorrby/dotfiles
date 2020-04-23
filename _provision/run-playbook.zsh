#!/usr/bin/env zsh

# ANSIBLE_STDOUT_CALLBACK=dense ansible-playbook playbook.yml "$@"
# ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook playbook.yml "$@"
ansible-playbook playbook.yml "$@"
