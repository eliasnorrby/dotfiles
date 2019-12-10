# Known problems (and how to fix them)

## Broken command tab-completion

```sh
rm ~/.zcompdump*
rm ~/.zplug/zcompdump* # On linux
rm /usr/local/opt/zplug/zcompdump # On mac
exec zsh
```

## Problems when installing mosh

When installing `mosh` using `brew install`, the following error can occur:

`Permission denied @ dir_s_mkdir - /usr/local/Frameworks`

To resolve, run:

`sudo install -d -o $(whoami) -g admin /usr/local/Frameworks`

[source](https://gist.github.com/irazasyed/7732946#gistcomment-2235469)

## Color inconsistencies with tmux / vim

> This complete .tmux.conf tells tmux to use xterm-256color as the terminal and then enables Tc

```conf
# Use the xterm-256color terminal
set -g default-terminal "xterm-256color"

# Apply Tc
set-option -ga terminal-overrides ",xterm-256color:Tc"
```

[source](https://github.com/tmux/tmux/issues/696#issuecomment-360629057)
