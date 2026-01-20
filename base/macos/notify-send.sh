#!/usr/bin/env bash

# Thin wrapper around terminal-notifier to provide notify-send compatibility on macOS.
# Usage: notify-send [SUMMARY] [BODY]

terminal-notifier -title "$1" -message "$2"
