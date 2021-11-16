#!/usr/bin/env bash

main() {
  local DIR_LIST=(
    "${HOME}/dev"
    "${HOME}/learn"
    "${HOME}/work"
  )

  for dir in "${DIR_LIST[@]}"; do
    local REPOS
    REPOS="${REPOS}\n$(find "${dir}" -maxdepth 3 -name ".git" -type d | sed 's/\/.git$//')"
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
