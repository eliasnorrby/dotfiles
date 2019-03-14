# My dotfiles
## Known problems (and how to fix them)
### Broken command tab-completion
```
rm ~/.zcompdump*
rm ~/.zplug/zcompdump* # On linux
rm /usr/local/opt/zplug/zcompdump # On mac
exec zsh
```

### Problems when installing mosh
When installing `mosh` using `brew install`, the following error can occur:

`Permission denied @ dir_s_mkdir - /usr/local/Frameworks`

To resolve, run:

`sudo install -d -o $(whoami) -g admin /usr/local/Frameworks`

[source](https://gist.github.com/irazasyed/7732946#gistcomment-2235469)

### Color inconsistencies with tmux / vim
This complete .tmux.conf tells tmux to use xterm-256color as the terminal and then enables Tc

```conf
# Use the xterm-256color terminal
set -g default-terminal "xterm-256color"

# Apply Tc
set-option -ga terminal-overrides ",xterm-256color:Tc"
```

[source](https://github.com/tmux/tmux/issues/696#issuecomment-360629057)

## 2019-02-09
Getting ready to perform the first installation on another Mac. Here's an attempt at some installation steps:

1. Download and install Karabiner Elements
2. Download and install Hammerspoon
3. Clone this repo into `~/.dotfiles`
  a. Create a copy of the default Karabiner config folder in `~/.config`
4. Execute the `setup_symlinks.sh` script
5. If not installed already, download `brew`
6. Install extra command line tools:
  a. zplug
  b. tmux
  c. fzf
    i. run `$(brew --prefix)/opt/fzf/install` to finish installation
  d. coreutils (for dircolors)
  e. vim (for a version compiled with clipboard support)
  f. mosh
  g. docker
  ...
7. Install Nerd fonts (in Dropbox/Common)
8. Download iTerm color schemes

## 2018-11-09
I haven't decided on a final structure or separation of concerns for these yet, but I thought it best to perform an initial commit sooner rather than later for backup purposes. As it stands now:

- `.zshrc` 
- `.zsh_aliases`
- `.zsh_powerlevel9k_default` has some sort-of-default theme settings

`.zshrc` contains almost all zsh configurations and sources `.zsh_aliases`. I'll begin now to reorganize and use zplug for plugin management. 
