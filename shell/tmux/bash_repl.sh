#!/usr/bin/env bash

SCRIPT=repl.sh
WINDOW_NAME=repl

window_name=$(tmux display-message -p "#W")
if [[ "$window_name" != "$WINDOW_NAME" ]]; then
  tmux rename-window "$WINDOW_NAME"
fi

cd "$(mktemp -d)" || exit 1

touch "$SCRIPT"
chmod +x "$SCRIPT"
cat <<EOF > "$SCRIPT"
#!/usr/bin/env bash

echo "Hello World!"
EOF

tmux split-window -t "$WINDOW_NAME" -h -d "echo $SCRIPT | entr /_"

nvim "$SCRIPT"
