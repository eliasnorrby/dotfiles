#!/usr/bin/env bash

# topic_config_files=$(find ./shell/zsh -type f -name topic.config.yml)
topic_config_files=$(find . -type f -name topic.config.yml)

function get_complete_list() {
  [ -z "$1" ] && echo "Must provide a key" && return 1
  local config_key=$1
  local values=""
  for topic_file in ${topic_config_files[@]}; do
    local topic_name=${topic_file%/*}
    local topic_name=${topic_name##*/}
    local topic_values=$(yq eval ".${topic_name}_config.${config_key}" $topic_file -j | jq -r '.[]?')
    values="$values $topic_values"
  done

  values=$(echo $values | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

  echo $values
}
