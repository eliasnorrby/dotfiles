#!/usr/bin/env zsh

cd ${${(%):-%x}:A:h}

plugins=("${(@f)$(yq r topic.config.yml 'vscode_plugins' -j | jq -r '.[]')}")

if [ -z "$plugins" ]; then
  echo "No vscode plugins found"
fi

for plugin in ${plugins[@]}; do
  code --install-extension $plugin
done
