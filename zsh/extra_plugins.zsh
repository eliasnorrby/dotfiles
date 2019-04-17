# =============================================================================
#                                   Plugins
# =============================================================================

# This should be a file containing less-used plugins or stuff to investigate, 
# but it is poorly maintained, so I don't know .

zplug "djui/alias-tips"

zplug "plugins/colored-man-pages", from:oh-my-zsh

# zplug "bobthecow/git-flow-completion", if:"(( $+commands[git] ))"

#zplug "plugins/golang",            from:oh-my-zsh, if:"(( $+commands[go] ))"
#zplug "plugins/node",              from:oh-my-zsh, if:"(( $+commands[node] ))"
# zplug "plugins/npm",               from:oh-my-zsh, if:"(( $+commands[npm] ))"
#zplug "plugins/pip",               from:oh-my-zsh, if:"(( $+commands[pip] ))"
# zplug "plugins/docker",            from:oh-my-zsh, if:"(( $+commands[docker] ))"
# zplug "plugins/docker-compose",    from:oh-my-zsh, if:"(( $+commands[docker-compose] ))"
zplug "plugins/mvn",               from:oh-my-zsh, if:"(( $+commands[mvn] ))"
# zplug "plugins/kubectl",            from:oh-my-zsh, if:"(( $+commands[kubectl] ))"

npm completion &> /dev/nulld

zplug "hlissner/zsh-autopair"

# if [[ $OSTYPE = (darwin)* ]]; then
#     zplug "lib/clipboard",         from:oh-my-zsh
#     #zplug "plugins/osx",           from:oh-my-zsh
#     zplug "plugins/brew",          from:oh-my-zsh, if:"(( $+commands[brew] ))"
#     #zplug "plugins/macports",      from:oh-my-zsh, if:"(( $+commands[port] ))"
# fi

# Check these out later
#zplug "plugins/colorize",          from:oh-my-zsh
#zplug "plugins/command-not-found", from:oh-my-zsh
#zplug "plugins/copydir",           from:oh-my-zsh
#zplug "plugins/copyfile",          from:oh-my-zsh
#zplug "plugins/cp",                from:oh-my-zsh
#zplug "plugins/dircycle",          from:oh-my-zsh
#zplug "plugins/encode64",          from:oh-my-zsh
#zplug "plugins/extract",           from:oh-my-zsh
#zplug "plugins/history",           from:oh-my-zsh
#zplug "plugins/tmux",              from:oh-my-zsh
#zplug "plugins/tmuxinator",        from:oh-my-zsh
#zplug "plugins/urltools",          from:oh-my-zsh
#zplug "plugins/web-search",        from:oh-my-zsh
#zplug "plugins/fancy-ctrl-z",      from:oh-my-zsh

zplug load
# compinit
