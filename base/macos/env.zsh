# Add brew to path
path=( /usr/local/{s,}bin $path  )

# Override system curl
path=( /usr/local/opt/curl/bin $path )

export XDG_RUNTIME_DIR=${HOME}/.run
