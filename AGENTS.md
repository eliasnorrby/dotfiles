# CLAUDE.md

This file provides guidance to agents (Claude, Cursor, Copilot, etc) when working with code in this repository.

## Overview

This is a declarative dotfiles repository for development on MacOS (Darwin) and Arch Linux (Manjaro). The architecture is topic-based, where each configuration domain (shell, editor, terminal, etc.) is organized into independent "topics" that declare their dependencies, symlinks, and platform-specific behaviors.

## Architecture

### Topic-Based System

The repository uses a hierarchical topic system inspired by hlissner's dotfiles:

```
{category}/{topic}/
  ├── topic.config.yml    # Required: declares dependencies, symlinks, packages
  ├── topic.tasks.yml     # Optional: ansible tasks to run during provisioning
  ├── aliases.zsh         # Optional: sourced during shell startup
  ├── env.zsh            # Optional: environment variables sourced during shell startup
  └── [config files]     # Topic-specific configuration files
```

**Categories**: `base`, `shell`, `editor`, `terminal`, `keyboard`, `lang`, `dev`, `wm`, `panel`, `tools`, `projects`, `hobby`

### Configuration Declaration

Topics declare their requirements in `topic.config.yml`:

```yaml
example_config:
  path: category/topic # Required: relative path from dotfiles root
  dirname: custom-name # Optional: override directory name for symlink
  links: # Symlinks to create in $HOME/.config/dirname or $HOME
    - file.conf # Simple link
    - src: source.conf # Complex link with conditions
      dest: "{{ xdg_bin_home }}" # Custom destination
      rename: newname
      condition: "{{ is_macos }}" # Platform-specific
  brew_formulae: [] # MacOS homebrew packages
  brew_casks: [] # MacOS homebrew casks
  brew_taps: [] # MacOS homebrew taps
  pacman_packages: [] # Arch Linux pacman packages
  aur_packages: [] # Arch Linux AUR packages
  npm_packages: [] # Node packages
  pip_packages: [] # Python packages
  gem_packages: [] # Ruby gems
  mas_apps: [] # MacOS App Store apps
  osx_defaults: [] # MacOS defaults writes
```

### Root Configuration Files

Topics are enabled/disabled in platform-specific root configs:

- **`macos.config.yml`**: MacOS topic configuration
- **`arch.config.yml`**: Arch Linux topic configuration

Topics have three states:

- `present`: symlinks created, dependencies installed
- `disabled`: symlinks removed, dependencies left alone
- `absent`: symlinks removed, dependencies uninstalled

### Provisioning Flow

1. **Bootstrap** (`setup.sh` or `setup-linux.sh`):
   - Installs homebrew (MacOS) or ensures pacman (Arch)
   - Installs ansible and python3
   - Clones dotfiles to `~/.dotfiles`
   - Runs ansible playbook

2. **Ansible Playbook** (`_provision/playbook.yml`):
   - Discovers all `topic.config.yml` files recursively
   - Sources platform-specific root config
   - Creates symlinks for `present` topics
   - Installs dependencies (brew/pacman/npm/pip/gem)
   - Runs platform-specific tasks (osx-defaults, etc.)
   - Executes topic-specific `topic.tasks.yml` files

3. **Post-Install** (`post-install.zsh`):
   - Installs tmux terminfo (MacOS)
   - Syncs neovim plugins (PackerSync)
   - Syncs doom-emacs packages
   - Installs vscode extensions
   - Enables node corepack
   - Installs ansible galaxy roles

## Common Development Commands

### Provisioning & Updates

```bash
# Initial bootstrap (from fresh machine)
bash <(curl -sL https://raw.githubusercontent.com/eliasnorrby/dotfiles/develop/setup.sh)

# Re-run provisioning after config changes
cd ~/.dotfiles/_provision
ansible-playbook playbook.yml --tags bootstrap

# Apply specific provisioning tasks
ansible-playbook playbook.yml --tags do_homebrew
ansible-playbook playbook.yml --tags do_defaults

# Run post-install steps
cd ~/.dotfiles && ./post-install.zsh
```

### Dotfiles CLI

The repository includes a custom CLI tool (`@eliasnorrby/dotfiles-cli`) configured via `dotfiles/cli/boomrc.{macos,arch}.js`:

```bash
# Edit platform root config
boom edit

# View current configuration
boom show

# Apply changes (runs ansible playbook)
boom deploy
```

The CLI provides shortcuts for editing and applying dotfile configurations without navigating to the `_provision` directory.

### Testing Changes

```bash
# Lint yaml files
yamllint .

# Test ansible playbook syntax
cd _provision
ansible-playbook playbook.yml --syntax-check

# Dry-run ansible playbook
ansible-playbook playbook.yml --check --diff
```

## Key Components

### Shell (ZSH)

- **Location**: `shell/zsh/`
- Primary shell with extensive configuration split across multiple files:
  - `config.zsh`: core zsh settings
  - `aliases.zsh`: command aliases
  - `keybinds.zsh`: key bindings
  - `completion.zsh`: completion system
  - `plugins.zsh`: plugin loading
  - `starship.zsh`: starship prompt configuration
  - `fzf.zsh`: fuzzy finder integration
- Environment variables and aliases from all enabled topics are automatically sourced during startup

### Editor (Neovim)

- **Location**: `editor/neovim/`
- **Config**: `init.lua` with modular lua configuration
- Plugins managed via Packer (synced in post-install)
- Dependencies include: fzf, bat, stylua, glow, eslint_d, kulala-ls

### Terminal Multiplexer (Tmux)

- **Location**: `shell/tmux/`
- **Config files**: `tmux.conf`, `tmux.theme.conf`, `tmux.remote.conf`
- Custom scripts in `scripts/` and `extensions/`
- Utility scripts symlinked to `$XDG_BIN_HOME`:
  - `tmux_switch_session`: fuzzy session switcher
  - `navigate`: MacOS-specific navigation (MacOS only)
  - `bash_repl`: embedded bash REPL
  - `tmux_warning_wrapper`: warning display wrapper
  - `tmux_active_pane_directory`: get active pane directory

### Git Configuration

- **Location**: `shell/git/`
- Standard git config with platform-specific behaviors
- GitHub CLI configuration in `gh-config.yml`

## Platform-Specific Behavior

### MacOS

- Uses **homebrew** for package management
- Supports **mas** (Mac App Store CLI)
- Includes keyboard customization via **Hammerspoon** and **Karabiner**
- Text expansion via **Espanso**
- Window management via **Amethyst**
- MacOS defaults applied via `tasks/osx-defaults.yml`

### Arch Linux

- Uses **pacman** and **AUR** for package management
- Window manager: **bspwm** with **polybar** panel
- Hotkey daemon: **sxhkd**
- Notification daemon: **dunst**
- Application launcher: **rofi**
- Compositor: **picom**

## Important Variables

The provisioning system uses ansible variables defined in `_provision/vars.yml`:

- `dotfiles`: Path to dotfiles directory (default: `~/.dotfiles`)
- `dotfiles_data`: Path for topic data storage
- `xdg_bin_home`: User bin directory for executable scripts
- `is_macos`: Boolean for platform detection
- `is_arch`: Boolean for platform detection

## Editing Topics

When modifying topic configurations:

1. Edit the `topic.config.yml` in the topic directory
2. Update platform root config (`macos.config.yml` or `arch.config.yml`) to set topic state
3. Run `boom apply` or manually run ansible playbook
4. For plugin/package changes, may need to run `post-install.zsh`

## Adding New Topics

1. Create directory structure: `{category}/{topic}/`
2. Add `topic.config.yml` with required `path` field and other declarations
3. Add topic to platform root config (`macos.config.yml` or `arch.config.yml`)
4. Run provisioning to create symlinks and install dependencies

## Scripts Directory

`scripts/` contains utility scripts for various tasks:

- `bootstrap-project.sh`: project initialization
- `merge-dependabot-prs.sh`: GitHub automation
- `find-git-changes.sh`: git utilities
- `update-remote.sh`: remote management

These scripts are general utilities and not automatically symlinked unless declared in a topic.

When writing shell scripts, use a 2 space indent. Lint these files with shellcheck and format them with shfmt before committing. Do not pass any flags to shfmt as it relies on editorconfig for configuration.
