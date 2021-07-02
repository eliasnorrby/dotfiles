#!/bin/sh

# Updates the token for the user for the current context.

token=$1

[ -z "$token" ] && { echo "Must supply token" && exit 1; }

current_context=$(kubectl config current-context)
current_context_user=$(kubectl config view -o json | jq -r '.contexts[] | select(.name == "'"$current_context"'").context.user')
kubectl config set-credentials "$current_context_user" --token "$token"
