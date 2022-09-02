#!/usr/bin/env bash

main() {
  local script mode=$1
  script=$(select_script)
  if [[ -z "$script" ]]; then
    return
  fi

  if [[ "$mode" == "append" ]]; then
    run_script_in_appended_window "$script"
  else
    run_script_in_main "$script"
  fi
}

select_script() {
  local repo_root package_dir script runner
  package_dir="$(pwd)"
  repo_root="$(git rev-parse --show-toplevel)"
  if [[ ! -f package.json ]]; then
    if [[ ! -f "${repo_root}/package.json" ]]; then
      return
    else
      package_dir="$repo_root"
    fi
  fi
  if [[ -f yarn.lock ]] \
    || [[ -f "${package_dir}/yarn.lock" ]] \
    || [[ -f "${repo_root}/yarn.lock" ]]; then
    runner=yarn
  else
    runner="npm run"
  fi
  script=$(jq -r '.scripts' "${package_dir}/package.json" \
    | jq 'keys[]' \
    | sed 's/"//g' \
    | package_dir="$package_dir" fzf --ansi --reverse \
      --preview 'jq -r ".scripts[\"$(echo {})\"]" "'"${package_dir}"'/package.json" | bat -l sh --color always --decorations never')
  if [[ -z "$script" ]]; then
    return
  fi
  echo "${runner} ${script}"
}

run_script_in_main() {
  local script=$1
  tmux new-window -n runner -t "2nd:0" -k "$(get_window_command "$script")"
}

run_script_in_appended_window() {
  local script=$1
  tmux new-window -n "$script" -t "2nd:1" -b "$(get_window_command "$script")"
}

get_window_command() {
  local script=$1
  echo "eval '$script' && sleep 2 || exec zsh"
}

main "$@"
