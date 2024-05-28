# Some brew casks (like Docker) install binaries in /usr/local/bin.
path=( /usr/local/{s,}bin $path  )

export XDG_RUNTIME_DIR=${HOME}/.run
