#!/bin/sh

# Browse hyprland clients with fzf
# - Enter: focus selected window
# - Ctrl+Y: yank class to clipboard

get_clients() {
  hyprctl clients -j | jq -r '.[] | "\(.address)\t\(.class)\t\(.title)\t\(.workspace.name)"'
}

preview_client() {
  address="$1"
  hyprctl clients -j | jq ".[] | select(.address == \"$address\")"
}

main() {
  selected=$(get_clients | fzf \
    --delimiter='\t' \
    --with-nth=2,3,4 \
    --preview="$0 --preview {1}" \
    --preview-window=right:50%:wrap \
    --bind="ctrl-y:execute-silent(echo -n {2} | wl-copy)+abort" \
    --header="Enter: focus | Ctrl+Y: yank class")

  [ -z "$selected" ] && exit 0

  address=$(echo "$selected" | cut -f1)
  hyprctl dispatch focuswindow "address:$address"
}

case "$1" in
  --preview)
    preview_client "$2"
    ;;
  *)
    main
    ;;
esac
