NPM_PACKAGES="${XDG_CACHE_HOME}/npm-global"

path=("$NPM_PACKAGES/bin" $path)

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

if [ "$(_os)" = "arch" ]; then
  nvm() {

    unfunction "$0"

    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    source /usr/share/nvm/nvm.sh
    source /usr/share/nvm/install-nvm-exec

    $0 "$@"
  }
fi

_is_callable fnm && eval "$(fnm env)"
