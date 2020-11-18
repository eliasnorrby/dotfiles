NPM_PACKAGES="${XDG_CACHE_HOME}/npm-global"

path=("$NPM_PACKAGES/bin" $path)

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
