#!/bin/sh

is_callable() {
  command -v "$1" >/dev/null
}

kubectl_context() {
  is_callable kubectl && kubectl config current-context >/dev/null 2>&1 || return
  context=$(kubectl config current-context)
  context=${context:-?}
  format="#[fg=cyan]ﴱ $context"
  if [ "$context" != "?" ]; then
    namespace=$(kubectl config view -o json \
      | jq -r '.contexts[] | select(.name == "'"$context"'").context.namespace')
    if [ -n "$namespace" ] && [ "$namespace" != "null" ]; then
      format="$format : $namespace"
    fi
  fi
  format="$format#[fg=default]"
  echo "$format"
}

argocd_context() {
  is_callable argocd && argocd context >/dev/null 2>&1 || return
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

ngrok_tunnel() {
  is_callable ngrok || return
  pgrep -x ngrok || return
  format="#[fg=green]  ngrok#[fg=default]"
  echo "$format"
}

gcloud_project() {
  is_callable gcloud || return
  configuration=$(gcloud config configurations list --format 'value(name)' --filter 'is_active:true')
  project=$(gcloud config get project --quiet)
  format="#[fg=blue] ${configuration}:${project}#[fg=default]"
  echo "$format"
}

for item in "$(ngrok_tunnel)" "$(kubectl_context)" "$(argocd_context)" "$(gcloud_project)" "$(node_version)" "$(java_version)"; do
  [ -z "$item" ] && continue
  printf '%s  ' "$item"
done
