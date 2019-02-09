# My dotfiles
## Known problems (and how to fix them)
### Broken command tab-completion
```
rm ~/.zcompdump*
rm ~/.zplug/zcompdump* # On linux
rm /usr/local/opt/zplug/zcompdump # On mac
exec zsh
```

## 2019-02-09
Getting ready to perform the first installation on another Mac. Here's an attempt at some installation steps:

1. Download and install Karabiner Elements
2. Download and install Hammerspoon
3. Clone this repo into `~/.dotfiles`
  a. Create a copy of the default Karabiner config folder in `~/.config`
4. Execute the `setup_symlinks.sh` script
5. Install extra command line tools:
  a. tmux
  b. fzf
  c. docker
  ...
6. Install Nerd fonts (in Dropbox/Common)
7. Download iTerm color schemes

## 2018-11-09
I haven't decided on a final structure or separation of concerns for these yet, but I thought it best to perform an initial commit sooner rather than later for backup purposes. As it stands now:

- `.zshrc` 
- `.zsh_aliases`
- `.zsh_powerlevel9k_default` has some sort-of-default theme settings

`.zshrc` contains almost all zsh configurations and sources `.zsh_aliases`. I'll begin now to reorganize and use zplug for plugin management. 
