# .DOTFILES

[![Travis][travis-badge]][travis-link]

[![Dependabot Status][dependabot-link]][dependabot-link]
[![semantic-release][semantic-release-badge]][semantic-release-link]

Declarative dotfiles for development on MacOS.

## Getting started

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
  - `doom-emacs` packages are installed

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
a `config.yml`, and can optionally include an `aliases.zsh`, an `env.zsh`, as
well as any other files relevant to its configuration.

Environment variables defined in `env.zsh` will be sourced during shell startup
if the topic is enabled. The same is true for aliases defined in `aliases.zsh`.

```
.dotfiles
└── group
    ├── topic
    │   ├── aliases.zsh
    │   ├── env.zsh
    │   └── config.yml
    └── another-topic
```

_Minimal example of a topic directory layout_

<details>
  <summary>Extended directory layout example</summary>

```
.dotfiles
├── editor
│   ├── editorconfig
│   │   └── config.yml
│   ├── emacs
│   │   ├── aliases.zsh
│   │   ├── config.yml
│   │   ├── doom
│   │   │   ├── config.el
│   │   │   ├── init.el
│   │   │   └── packages.el
│   │   └── env.zsh
│   └── vim
│       ├── aliases.zsh
│       ├── config.yml
│       ├── env.zsh
│       └── gvimrc.vim
├── env
└── shell
   ├── alacritty
   │   ├── alacritty.yml
   │   ├── aliases.zsh
   │   └── config.yml
   ├── git
   │   ├── aliases.zsh
   │   └── config.yml
   ├── tmux
   │   ├── aliases.zsh
   │   ├── config.yml
   │   ├── env.zsh
   │   ├── scripts
   │   │   └── uptime-tmux-status.sh
   │   ├── tmux-cheatsheet.md
   │   ├── tmux.conf
   │   ├── tmux.remote.conf
   │   └── tmux.theme.conf
   └── zsh
       ├── aliases.zsh
       ├── completion.zsh
       ├── config.yml
       ├── config.zsh
       ├── fzf.zsh
       ├── keybinds.zsh
       ├── macos.zsh
       ├── plugins.zsh
       ├── prompt.zsh
       ├── remote.zsh
       └── utilities.zsh
```

</details>

Each topic declares it's configuration (brew dependencies, symlinks, etc) in a
`config.yml` within its coresponding directory.

```yaml
vim_config:
  path: editor/vim
  links:
    - .vimrc
  brew_formulas:
    - vim
```

_Topic configuration example_

Possible fields in topic `config.yml`:

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

Each topic configuration is mapped to the root `config.yml`:

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

In the root `config.yml`, topics can be enabled/disabled/removed by setting
their `state` to one of `present`, `disabled` or `absent`. Upon running,

- `present` topics will have their symlinks created (if they don't exist
  already) and their dependencies installed
- `disabled` topics will have their symlinks removed (if they exist), but their
  dependencies left alone (if they are installed)
- `absent` topics will have their symlinks remove (if they exist) and their
  dependencies uninstalled (if they are installed)

:warning: `disabled` and `absent` states are currently only being ignored
entirely during playbook runs (marking a topic as `absent` does not remove it).
See the `next` branch for progress on this feature.

[travis-badge]: https://img.shields.io/travis/com/eliasnorrby/dotfiles?style=for-the-badge
[travis-link]: https://travis-ci.com/eliasnorrby/dotfiles
[dependabot-badge]: https://api.dependabot.com/badges/status?host=github&repo=eliasnorrby/dotfiles
[dependabot-link]: https://dependabot.com
[semantic-release-badge]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
[semantic-release-link]: https://github.com/semantic-release/semantic-release
[geerlingguy-homebrew-link]: https://homebrewhub.com/geerlingguy/ansible-role-homebrew
[geerlingguy-git-link]: https://github.com/geerlingguy/ansible-role-git
[hlissner-dotfiles-link]: https://github.com/hlissner/dotfiles
