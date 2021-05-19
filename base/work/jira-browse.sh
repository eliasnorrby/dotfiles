#!/bin/sh

menu() {
  rofi -dmenu -i -width 15 -monitor primary "$@"
}

CONF_DIR="${XDG_CONFIG_HOME:-~/.config}/jira"
URL_FILE="$CONF_DIR/baseurl"
PROJECTS_FILE="$CONF_DIR/projects"

[ ! -f "$URL_FILE" ] && exit 1
BASEURL=$(cat "$URL_FILE")
PROJECTS=$(cat "$PROJECTS_FILE")

project=$(echo "$PROJECTS" | menu -p "Pick a project" -lines 5)
[ -z "$project" ] && exit

number=$(menu -p "Type a ticket number" -lines 0)
[ -z "$number" ] && exit

xdg-open "${BASEURL}/${project}-${number}"
