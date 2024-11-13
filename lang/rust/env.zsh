export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# What rustup-init recommends
# . "~/.local/share/cargo/env"
path=( $CARGO_HOME/bin $path )
