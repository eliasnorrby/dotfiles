## [1.1.1](https://github.com/eliasnorrby/dotfiles/compare/v1.1.0...v1.1.1) (2019-12-15)


### Bug Fixes

* **deps:** [security] bump npm from 6.13.3 to 6.13.4 ([6d26c36](https://github.com/eliasnorrby/dotfiles/commit/6d26c369d58f12451115cc3940937630d6741b0c))

# [1.1.0](https://github.com/eliasnorrby/dotfiles/compare/v1.0.0...v1.1.0) (2019-12-13)


### Bug Fixes

* rename with_items -> loop ([9ffdaf2](https://github.com/eliasnorrby/dotfiles/commit/9ffdaf2a1686d5bb930237a6e0af2eb15c824127))
* **cicd:** temporarily remove travis gem ([1eba60b](https://github.com/eliasnorrby/dotfiles/commit/1eba60bab6f6b9fb06d869841e475740b630d4f5))
* use correct path for include tasks ([cf884a2](https://github.com/eliasnorrby/dotfiles/commit/cf884a274c452d77cc3cf90666232cf6fbf6c3f5))
* **emacs:** move gnupg from taps to formulas ([95a9df1](https://github.com/eliasnorrby/dotfiles/commit/95a9df1bdacf5ab22b754fda21a98caef9537455))
* **vagrant:** list vagrant as cask not formula ([4b72cf6](https://github.com/eliasnorrby/dotfiles/commit/4b72cf6f4dadc95eda2aafa62a59e976c2f9b963))
* **vim:** have neovim properly source .vimrc ([9679f10](https://github.com/eliasnorrby/dotfiles/commit/9679f10d29e3b70e2d16bd39f75f5c349e7f295a))
* **vim:** try to reconcile vim and nvim configs ([9397b83](https://github.com/eliasnorrby/dotfiles/commit/9397b830e9db14c147cd12fa40f7dcdf71656660))
* **zsh:** load utilities.zsh ([dc1ac93](https://github.com/eliasnorrby/dotfiles/commit/dc1ac931ed64754b0603906e438d586e58655286))


### Features

* prompt for MAS credentials ([51227fa](https://github.com/eliasnorrby/dotfiles/commit/51227fa56556df3e895a550bb416cd0e498fba2e))
* **brew:** update brew formula dependencies ([83da5ad](https://github.com/eliasnorrby/dotfiles/commit/83da5ad0e3c819b5e6bdb732980332f75a111e0d))
* **defaults:** add osx_defaults to topics ([8a4f380](https://github.com/eliasnorrby/dotfiles/commit/8a4f380fab008c13460087507ab8b76e226d2a4d))
* **dev:** add ansibe, cicd and web topics ([0946c39](https://github.com/eliasnorrby/dotfiles/commit/0946c39f952061d3434c192d3d25b6a1311681b0))
* **emacs:** enable flyspell and dired icons ([ec3751a](https://github.com/eliasnorrby/dotfiles/commit/ec3751adc6cb21d4a67bfb62384074a73c2dc532))
* **git:** add gse alias to stash everything ([5ba8027](https://github.com/eliasnorrby/dotfiles/commit/5ba8027cdb58eca1835f4d475425c5d153c1ada6))
* **lang:** install ruby and python ([0e59c74](https://github.com/eliasnorrby/dotfiles/commit/0e59c740801908bbed8c289c3dd275cd29b31cf3))
* **macos:** add app store apps ([75abc14](https://github.com/eliasnorrby/dotfiles/commit/75abc14113d62e9445ff2427480bdb4434bde492))
* **macos:** add cask fonts ([0223745](https://github.com/eliasnorrby/dotfiles/commit/02237459535d6728ee6f034e6cd79a3eff939e8c))
* **vim:** add aliases for cd and gitignore ([e1a98ab](https://github.com/eliasnorrby/dotfiles/commit/e1a98abeb64f94e3cbbb9f4580b944eb387a46be))
* **zsh:** alias ls to list directories first ([eed9eec](https://github.com/eliasnorrby/dotfiles/commit/eed9eecd9b35b0a3aaf4d7e7a63d505e4ee570e5))
* add kafka, node and bash topics ([cc12a52](https://github.com/eliasnorrby/dotfiles/commit/cc12a5264cfcbf4b0a945e0badac8f2b743aeb56))
* add kubernetes, vagrant and vscode topics ([ebf7e34](https://github.com/eliasnorrby/dotfiles/commit/ebf7e34acc35a26c50b66410bb5d28252b8e6df7))
* add macos cask apps ([f93645c](https://github.com/eliasnorrby/dotfiles/commit/f93645c7425d3fcadac27908d93fd9e75694dce6))
* **script:** add link-to-bin script ([73699d7](https://github.com/eliasnorrby/dotfiles/commit/73699d7c838aca7788ad761a85838a54679d3252))
* **script:** finalize bootstrap-project script ([0f04db2](https://github.com/eliasnorrby/dotfiles/commit/0f04db2e5cf389342721c8fd65daedfc7f3209df))
* **scripts:** default to src without file ending ([f2f7f53](https://github.com/eliasnorrby/dotfiles/commit/f2f7f533d3b08954ae33f389049e30d133257786))
* download playbook@master in bootstrap ([051b1dd](https://github.com/eliasnorrby/dotfiles/commit/051b1dd0e3e8e7b6b5b22dc7d78d226cdf7f5e0e))
* **vim:** revive old keybinds for save and quit ([815a501](https://github.com/eliasnorrby/dotfiles/commit/815a5011bc969c0feb6fc658bbd9a4b6f4efb5d6))
* **zsh:** add alias to cd to topic directory ([eacb6ff](https://github.com/eliasnorrby/dotfiles/commit/eacb6ff4cdd4dcd0089784929cc52084c4109ecb))

# 1.0.0 (2019-12-11)


### Bug Fixes

* **zsh:** fix broken ls after path refactor ([a2ae67d](https://github.com/eliasnorrby/dotfiles/commit/a2ae67db2eaabe94996f5ce1d343f5d52802bb85))
* **zsh:** load fzf.zsh after zplug load ([bc9f8c2](https://github.com/eliasnorrby/dotfiles/commit/bc9f8c254c723a3147e1e6038ff5c0cb8120c52b))


### Features

* **zsh:** add alias vp="vim package.json" ([2ea84ac](https://github.com/eliasnorrby/dotfiles/commit/2ea84ac6408825dde3e7ff5aac4fb162a68b8bbb))
* add macos topic ([5b42a80](https://github.com/eliasnorrby/dotfiles/commit/5b42a802be9a4fcf96b5e5df3be95152cbb2c772))
* get latest version of playbook in bootstrap ([f14b502](https://github.com/eliasnorrby/dotfiles/commit/f14b5021a2c2ec8e70c80ee476b314074a34a9a4))

# 1.0.0-beta.1 (2019-12-10)


### Bug Fixes

* **zsh:** fix broken ls after path refactor ([a2ae67d](https://github.com/eliasnorrby/dotfiles/commit/a2ae67db2eaabe94996f5ce1d343f5d52802bb85))


### Features

* add macos topic ([5b42a80](https://github.com/eliasnorrby/dotfiles/commit/5b42a802be9a4fcf96b5e5df3be95152cbb2c772))
* get latest version of playbook in bootstrap ([f14b502](https://github.com/eliasnorrby/dotfiles/commit/f14b5021a2c2ec8e70c80ee476b314074a34a9a4))
