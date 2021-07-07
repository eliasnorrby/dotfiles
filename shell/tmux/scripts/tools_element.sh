#!/bin/sh

is_callable() {
  command -v "$1" >/dev/null
}

kubectl_context() {
  is_callable kubectl || return
  context=$(kubectl config current-context)
  format="#[fg=cyan]ﴱ $context"
  namespace=$(kubectl config view -o json \
    | jq -r '.contexts[] | select(.name == "'"$context"'").context.namespace')
  if [ -n "$namespace" ] && [ "$namespace" != "null" ]; then
    format="$format : $namespace"
  fi
  format="$format#[fg=default]"
  echo "$format"
}

argocd_context() {
  is_callable argocd || return
  context=$(argocd context | grep '^\*' | tr -s ' ' | cut -d ' ' -f 2)
  format="#[fg=red] $context#[fg=default]"
  echo "$format"
}

node_version() {
  is_callable node || return
  version=$(node --version | cut -d '.' -f 1)
  format="#[fg=green] $version#[fg=default]"
  echo "$format"
}

java_version() {
  is_callable java || return
  version=$(java --version | head -1 | cut -d ' ' -f 2 | cut -d '.' -f 1)
  format="#[fg=gray] $version#[fg=default]"
  echo "$format"
}

for item in "$(kubectl_context)" "$(argocd_context)" "$(node_version)" "$(java_version)"; do
  [ -z "$item" ] && continue
  printf '%s  ' "$item"
done
