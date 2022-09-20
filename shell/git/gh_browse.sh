#!/usr/bin/env bash

main() {
  local DIR_LIST=(
    "${HOME}/dev"
    "${HOME}/learn"
    "${HOME}/work"
  )

  local REPOS
  for dir in "${DIR_LIST[@]}"; do
    local dir_repos
    dir_repos=$(find "${dir}" -maxdepth 3 -name ".git" -type d | sed 's/\/.git$//')
    if [[ -z "${dir_repos}" ]]; then
      continue
    fi
    REPOS="${REPOS}\n${dir_repos}"
  done

  local TARGET
  TARGET="$(echo -e "$REPOS" \
    | sed "s#$HOME##" \
    | fzf --border --tac \
      --preview "tree -C -I node_modules -L 3 ${HOME}{}")"

  if [[ -n "$TARGET" ]]; then
    cd "${HOME}/${TARGET}" || exit 1
    gh browse
  fi
}

main
