# [1.4.0](https://github.com/eliasnorrby/dotfiles/compare/v1.3.0...v1.4.0) (2020-02-25)


### Bug Fixes

* **emacs:** bind vim window movement to n map ([dff2c28](https://github.com/eliasnorrby/dotfiles/commit/dff2c2827f756b8e704df2bab9d8441935eb0e28))


### Features

* **emacs:** add react snippets ([03d44f2](https://github.com/eliasnorrby/dotfiles/commit/03d44f2b5a485b04926e49d2fd479247adc4e877))
* **emacs:** enable lsp mode for javascript/typescript ([c7ff7a5](https://github.com/eliasnorrby/dotfiles/commit/c7ff7a5916aaa77f92579d24f1362edb3933a1e2))
* **gcloud:** add gcloud topic ([89ec70a](https://github.com/eliasnorrby/dotfiles/commit/89ec70ae92ee1eb29cf4c57466630cc9d717ec87))
* **java:** default to java13 ([094e339](https://github.com/eliasnorrby/dotfiles/commit/094e339fe6ae5e26748b28d13c47443d8d90777f))
* **provision:** log output of update script ([bd2f4c7](https://github.com/eliasnorrby/dotfiles/commit/bd2f4c71cce1592c0e49ae700961cd73ff5a20aa))
* **provision:** update npm packages in update-all ([67c2b5a](https://github.com/eliasnorrby/dotfiles/commit/67c2b5ac031aae8b7a235b5db82f6258cf5493f8))
* **python:** use brew's python before system ([d65160f](https://github.com/eliasnorrby/dotfiles/commit/d65160ff8f9d1eec9d049b0cea76e85651885864))
* **scripts:** add more checks to bootstrap-project ([74a9c7d](https://github.com/eliasnorrby/dotfiles/commit/74a9c7d0f216f8f147ef9d1e485d480513c0b735))
* **web:** add cra alias ([3164bac](https://github.com/eliasnorrby/dotfiles/commit/3164bac38a66116a113919dda72763c28bc73aad))
* format manually ([7efaee4](https://github.com/eliasnorrby/dotfiles/commit/7efaee4385673238764f0d67abd3f46725c6d28a))
* **web:** add firebase-tools ([993556b](https://github.com/eliasnorrby/dotfiles/commit/993556bc4c8f49011ae43ec62ffb7f39de9ebfa7))

# [1.3.0](https://github.com/eliasnorrby/dotfiles/compare/v1.2.0...v1.3.0) (2020-01-08)


### Bug Fixes

* **scripts:** print newline before cleanup ([dd29a56](https://github.com/eliasnorrby/dotfiles/commit/dd29a56a8e4548cbf0ce6deb384c4338ddac745c))
* **tmux:** escape backslashes in config ([708df13](https://github.com/eliasnorrby/dotfiles/commit/708df131f8a5a136f3d291643ddcead5606e6180))
* include coreutils in path ([6713bd8](https://github.com/eliasnorrby/dotfiles/commit/6713bd8b08124b99ad9ea66ad991785dcd8c4af8))


### Features

* **cli:** provide script for running playbook ([f67be01](https://github.com/eliasnorrby/dotfiles/commit/f67be01513dfa544a092bccbc70baf38f27e91a8))
* **git:** use diff-so-fancy for diffs ([d634c71](https://github.com/eliasnorrby/dotfiles/commit/d634c71246e1d7de944ec1746b8fb85e5788cd11))
* **scripts:** add duration to slack notification ([efa3bac](https://github.com/eliasnorrby/dotfiles/commit/efa3bac6e3bf33f7cd79c95a3043e38986c2e703))
* **scripts:** add echo-input to print prefix ([fe441a1](https://github.com/eliasnorrby/dotfiles/commit/fe441a1d30cb43367bce8d9f1cf1467b4690b667))
* **scripts:** add echo-warn ([704ed64](https://github.com/eliasnorrby/dotfiles/commit/704ed645b080fbed9e1f6b24a2b48407831c2e91))
* **scripts:** improve bootstrap ([c708b85](https://github.com/eliasnorrby/dotfiles/commit/c708b85317462c9e11a2a5198dbc70e9a94746fa))
* **scripts:** use reference style links for badges ([1d15a1f](https://github.com/eliasnorrby/dotfiles/commit/1d15a1fb3504892581dd8451bb03103376f56674))
* add dotfiles/cli topic ([74a2cbd](https://github.com/eliasnorrby/dotfiles/commit/74a2cbdfd980db53f4a02438c1d77bf701ca1d1e))

# [1.2.0](https://github.com/eliasnorrby/dotfiles/compare/v1.1.1...v1.2.0) (2019-12-16)


### Bug Fixes

* **emacs:** disable flyspell ([3923797](https://github.com/eliasnorrby/dotfiles/commit/39237978fb6a62216c3ab9569f57a60029c2a9a0))


### Features

* **editorconfig:** set indent_size=4 for rust ([195d0e0](https://github.com/eliasnorrby/dotfiles/commit/195d0e07eabf5436ce3bfc803693bc8c937aff88))
* **emacs:** add rust module ([1f3e4e2](https://github.com/eliasnorrby/dotfiles/commit/1f3e4e2fef50cc59df6c72939cff4a6f71454845))
* **emacs:** enable ansible module ([7e36f87](https://github.com/eliasnorrby/dotfiles/commit/7e36f87f62d7b06b52e14dcd038e865576b75aa9))
* **git:** replace old git settings ([cbe34f9](https://github.com/eliasnorrby/dotfiles/commit/cbe34f9d73641bb427f9d684b6830476cb33cf80))
* **provision:** enable pipelining ([0881986](https://github.com/eliasnorrby/dotfiles/commit/088198611fb14fbbee1d12180804a5c56dc00848))
* **provision:** remove links for non-present topics ([44f12d6](https://github.com/eliasnorrby/dotfiles/commit/44f12d6ca48bca9432cdc9381518d5dab6844ae5))
* **provision:** use yaml stdout callback ([0481d71](https://github.com/eliasnorrby/dotfiles/commit/0481d71e76c1b791c6074dbd25bb78775268ba87))
* **scripts:** add better prints to complete-section ([dad7af7](https://github.com/eliasnorrby/dotfiles/commit/dad7af72849aaed7f48e6903340b4671aa0a2302))
* **scripts:** add short flag to git status ([e90f47c](https://github.com/eliasnorrby/dotfiles/commit/e90f47c5a19e1375535966816758d6f76802b1d4))
* **web:** add httpie brew formula ([02d8e14](https://github.com/eliasnorrby/dotfiles/commit/02d8e14e819fd2778d575df9fd2536c918828cb9))
* **zsh:** add map alias ([c5a2a85](https://github.com/eliasnorrby/dotfiles/commit/c5a2a858955363c8d729d0399b16d8b4a8af759c))
* add rust topic ([e0b495c](https://github.com/eliasnorrby/dotfiles/commit/e0b495cced1cf7fa8e58de5da0ffb1f0945c4ad7))

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
