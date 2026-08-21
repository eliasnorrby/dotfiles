# Fallback config for task_note when run from an interactive shell.
#
# The authoritative mapping lives on the taskwarrior-tui shortcut line in
# taskrc, because the TUI is usually launched from the .desktop entry
# ("kitty -e taskwarrior-tui") which execs the binary with no login shell
# and so never sees anything exported here.
export TASK_NOTE_VAULTS_DIR="$HOME/vaults"
export TASK_NOTE_DEFAULT_VAULT="personal"
export TASK_NOTE_PROJECT_VAULTS="work=bemlo"
