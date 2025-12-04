#!/usr/bin/env bash

WINDOW_NAME=jq-repl
QUERY_FILE=query.jq
INPUT_FILE=input.json
WRAPPER_SCRIPT=run.sh

# 1. Ensure window is named correctly
window_name=$(tmux display-message -p "#W")
if [[ "$window_name" != "$WINDOW_NAME" ]]; then
  tmux rename-window "$WINDOW_NAME"
fi

# 2. Create temporary directory
cd "$(mktemp -d)" || exit 1

# 3. Initialize query file with example query
cat <<'EOF' >"$QUERY_FILE"
.
EOF

# 4. Initialize input file with example JSON
cat <<'EOF' >"$INPUT_FILE"
{
  "example": "Paste your JSON here"
}
EOF

# 5. Create wrapper script that executes jq
cat <<'EOF' >"$WRAPPER_SCRIPT"
#!/usr/bin/env bash
jq -C -f query.jq input.json 2>&1
EOF
chmod +x "$WRAPPER_SCRIPT"

# 6. Split window and watch both files for changes
tmux split-window -t "$WINDOW_NAME" -h -d \
  "printf '%s\\n' '$QUERY_FILE' '$INPUT_FILE' | entr -c ./$WRAPPER_SCRIPT"

# 7. Open both files in nvim with vertical split
nvim -O "$QUERY_FILE" "$INPUT_FILE"
