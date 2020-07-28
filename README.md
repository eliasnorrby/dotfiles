# .DOTFILES

[![Travis][travis-badge]][travis-link]

[![Dependabot Status][dependabot-badge]][dependabot-link]
[![semantic-release][semantic-release-badge]][semantic-release-link]

Declarative dotfiles for development on MacOS.

## Bootstrap

To provision a new workstation from scratch, use the `bootstrap.sh` script.

> :warning: **Warning** :warning:
> This script has only been tested in CI. I have yet to try this on an actual
> machine myself.

Run

```bash
bash <(curl -s https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/bootstrap.sh)
```

This setup script will:

- Download a snapshot version of this repo
- Install `pip` (using `easy_install`)
- Install `ansible` (using `pip`)
- Run the downloaded playbook (`_provision/playbook.yml`), wherein:
  - This repo is cloned to `~/.dotfiles`
  - Symlinks are created
  - xcode command line tools are installed
  - Dependencies are downloaded (using `homebrew`, `pip`, `ruby` and `npm`)
- Run the post-install script, wherein:

  - `zsh` plugins are installed
  - `vim` plugins are installed
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
       └── topic.config.yml
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
- `brew_formulas`
- `brew_casks`
- `brew_taps`
- `osx_defaults`
- `npm_packages`
- `pip_packages`
- `gem_packages`

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

1. Set main Alfred hotkey to <kbd>⌥</kbd> + <kbd>SPACE</kbd>
2. Install the Things 3 helper
3. Download the [Dank Mono font](https://dank.sh)
4. Enable shortcuts for desktop navigation (Preferences -> Keyboard -> Shortcuts -> Mission Control)
5. Download Fluid and set up Gmail as a desktop app
6. Link the proper scripts to `~/.local/bin`. There's a helper in the `scripts` directory. This could be scripted.
7. ...?

[travis-badge]: https://img.shields.io/travis/com/eliasnorrby/dotfiles?style=for-the-badge
[travis-link]: https://travis-ci.com/eliasnorrby/dotfiles
[dependabot-badge]: https://api.dependabot.com/badges/status?host=github&repo=eliasnorrby/dotfiles
[dependabot-link]: https://dependabot.com
[semantic-release-badge]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
[semantic-release-link]: https://github.com/semantic-release/semantic-release
[geerlingguy-homebrew-link]: https://homebrewhub.com/geerlingguy/ansible-role-homebrew
[geerlingguy-git-link]: https://github.com/geerlingguy/ansible-role-git
[hlissner-dotfiles-link]: https://github.com/hlissner/dotfiles
[dotfiles-cli-link]: https://github.com/eliasnorrby/dotfiles-cli
