# .DOTFILES

[![Travis][travis-badge]][travis-link]

[![semantic-release][semantic-release-badge]][semantic-release-link]

Declarative dotfiles for development on MacOS.

## Bootstrap

To provision a new workstation from scratch, use the `setup.sh` script.

Run

```bash
bash <(curl -sL https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh)
```

Prepare to input your password a couple of times.

This setup script will:

- Install homebrew
- Install `python3` and `openssl` (using `brew`)
- Download a snapshot version of this repo
- Install `ansible` (using `pip`)
- Install `ansible` role dependencies
- Run the downloaded playbook (`_provision/playbook.yml`), wherein:
  - This repo is cloned to `~/.dotfiles`
  - Symlinks are created
  - xcode command line tools are installed (or verified to have been installed)
  - Dependencies are downloaded (using `homebrew`, `pip`, `ruby` and `npm`)
- Run the post-install script, wherein:

  - `zsh` plugins are installed
  - `vim` plugins are installed
  - `coc-nvim` extensions are installed
  - `vscode` plugins are installed
  - `doom-emacs` packages are installed

:clock1: Estimated duration: ~45 minutes

Dependencies:

- [geerlingguy/homebrew][geerlingguy-homebrew-link]
- [geerlingguy/git][geerlingguy-git-link]

## Directory structure

Configuration is divided into `topics` (inspired by
[hlissner][hlissner-dotfiles-link]).

Example topics:

- `shell/zsh`
- `shell/tmux`
- `editor/vim`

Topics are grouped by category (`editor`, `shell`, etc). Each topic must contain
a `topic.config.yml`, and can optionally include a `topic.tasks.yml`, an
`aliases.zsh`, an `env.zsh`, as well as any other files relevant to its
configuration.

Ansible tasks defined in `topic.tasks.yml` will be run during provisioning.

Environment variables defined in `env.zsh` will be sourced during shell startup
if the topic is enabled. The same is true for aliases defined in `aliases.zsh`.

```
.dotfiles
└── group
    ├── topic
    │   ├── aliases.zsh
    │   ├── env.zsh
    │   ├── topic.config.yml
    │   └── topic.tasks.yml
    └── another-topic
```

_Minimal example of a topic directory layout_

<details>
  <summary>Extended directory layout example</summary>

```
.dotfiles
├── editor
│   ├── editorconfig
│   │   └── topic.config.yml
│   ├── emacs
│   │   ├── aliases.zsh
│   │   ├── topic.config.yml
│   │   ├── doom
│   │   │   ├── config.el
│   │   │   ├── init.el
│   │   │   └── packages.el
│   │   └── env.zsh
│   └── vim
│       ├── aliases.zsh
│       ├── env.zsh
│       ├── gvimrc.vim
│       └── topic.config.yml
└── shell
   ├── alacritty
   │   ├── alacritty.yml
   │   ├── aliases.zsh
   │   └── topic.config.yml
   ├── git
   │   ├── aliases.zsh
   │   └── topic.config.yml
   ├── tmux
   │   ├── aliases.zsh
   │   ├── env.zsh
   │   ├── scripts
   │   │   └── uptime-tmux-status.sh
   │   ├── tmux-cheatsheet.md
   │   ├── tmux.conf
   │   ├── tmux.remote.conf
   │   ├── tmux.theme.conf
   │   └── topic.config.yml
   └── zsh
       ├── aliases.zsh
       ├── completion.zsh
       ├── config.zsh
       ├── fzf.zsh
       ├── keybinds.zsh
       ├── macos.zsh
       ├── plugins.zsh
       ├── prompt.zsh
       ├── remote.zsh
       ├── utilities.zsh
       ├── topic.config.yml
       └── topic.tasks.yml
```

</details>

Each topic declares its configuration (brew dependencies, symlinks, etc) in a
`topic.config.yml` within its coresponding directory.

```yaml
vim_config:
  path: editor/vim
  links:
    - .vimrc
  brew_formulas:
    - vim
```

_Topic configuration example_

Possible fields in `topic.config.yml`:

- `path` (required)
- `links`
- `become`
- `brew_formulas`
- `brew_casks`
- `brew_taps`
- `pacman_packages`
- `osx_defaults`
- `npm_packages`
- `pip_packages`
- `gem_packages`
- `mas_apps`

:bangbang: **TODO**: Describe topic config api in detail.

Each topic configuration is mapped to `root.config.yml`:

```yaml
topics:
  editor:
    - name: vim
      state: present
      config: "{{ vim_config }}"
    - name: emacs
      state: present
      config: "{{ emacs_config }}"
    - name: editorconfig
      state: disabled
      config: "{{ editorconfig_config }}"
  keyboard:
    - name: hammerspoon
      state: present
      config: "{{ hammerspoon_config }}"
    - name: karabiner
      state: present
      config: "{{ karabiner_config }}"
  shell:
    - name: tmux
      state: present
      config: "{{ tmux_config }}"
    - name: zsh
      state: present
      config: "{{ zsh_config }}"
  lang:
    - name: java
      state: present
      config: "{{ java_config }}"
    - name: go
      state: absent
      config: "{{ go_config }}"
```

_Root dotfile configuration example_

In `root.config.yml`, topics can be enabled/disabled/removed by setting
their `state` to one of `present`, `disabled` or `absent`. Upon running,

- `present` topics will have their symlinks created (if they don't exist
  already) and their dependencies installed
- `disabled` topics will have their symlinks removed (if they exist), but their
  dependencies left alone (if they are installed)
- `absent` topics will have their symlinks removed (if they exist) and their
  dependencies uninstalled (if they are installed)

## CLI

> :wrench: [eliasnorrby/dotfiles-cli][dotfiles-cli-link]

The CLI provides a simpler way to edit, view and apply configurations.

## Leftovers

After running the provisioning script, there are a few things that need to be
configured manually.

- Start all apps and prepare to grant lots of privileges
  - Start with Karabiner and Hammerspoon to enable app shortcuts
- Download the [Dank Mono font](https://dank.sh)
- Set main Alfred hotkey to <kbd>⌥</kbd> + <kbd>SPACE</kbd>
- Install the Things 3 helper
- Add additional desktops
- Enable shortcuts for desktop navigation (Preferences <kbd>→</kbd> Keyboard <kbd>→</kbd> Shortcuts <kbd>→</kbd> Mission Control)
- Set desktop backgrounds (assets available in Dropbox)
- Download Fluid and set up Gmail as a desktop app
- Configure Bartender to hide the appropriate icons, supply license
- Import iStatMenus settings from `assets/istatmenus`, supply license
- Link the proper scripts to `~/.local/bin`. There's a helper in the `scripts` directory. This could be scripted.
- Set the computer name
  - Preferences <kbd>→</kbd> Sharing
  - `sudo scutil --set HostName <name-you-want>`

- ...?

## Troubleshooting

### zsh: compinit complains about insecure directories

It's probably mentioning `/usr/local/share/zsh`. Resolve it by running e.g:

```bash
sudo chown -R eliasnorrby:admin /usr/local/share/zsh
sudo chmod -R 755 /usr/local/share/zsh
```

[travis-badge]: https://img.shields.io/travis/com/eliasnorrby/dotfiles?style=for-the-badge
[travis-link]: https://travis-ci.com/eliasnorrby/dotfiles
[semantic-release-badge]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
[semantic-release-link]: https://github.com/semantic-release/semantic-release
[geerlingguy-homebrew-link]: https://homebrewhub.com/geerlingguy/ansible-role-homebrew
[geerlingguy-git-link]: https://github.com/geerlingguy/ansible-role-git
[hlissner-dotfiles-link]: https://github.com/hlissner/dotfiles
[dotfiles-cli-link]: https://github.com/eliasnorrby/dotfiles-cli
