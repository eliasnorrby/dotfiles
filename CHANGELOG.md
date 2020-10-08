# [3.0.0](https://github.com/eliasnorrby/dotfiles/compare/v2.3.0...v3.0.0) (2020-10-08)


### Bug Fixes

* quote cli dependency ([ce40783](https://github.com/eliasnorrby/dotfiles/commit/ce407836cb9f35027258b2668c8f389cfef775a9))
* **provision:** unquote ansible flags ([b684825](https://github.com/eliasnorrby/dotfiles/commit/b68482571e5988087373d9df19d19b1b825b49b7))
* **scripts:** use printf ([6c69ca1](https://github.com/eliasnorrby/dotfiles/commit/6c69ca1ff587a1f58cc7f98fa0e5a23db1eb6fb7))


### Features

* **base:** replace lastpass with 1password ([beceea4](https://github.com/eliasnorrby/dotfiles/commit/beceea495b8579b8c2ef4b164caaa2919cb063f7))
* **bootstrap:** check for executables before install ([af9f0ef](https://github.com/eliasnorrby/dotfiles/commit/af9f0ef4b20b996e6592a0c448c27f69ddae258d))
* **bootstrap:** use updated ansible install process ([764e052](https://github.com/eliasnorrby/dotfiles/commit/764e0522d453383fbb160cea54d1bbc47a292531))
* **cli:** add cli and ansible to deps ([848e16f](https://github.com/eliasnorrby/dotfiles/commit/848e16fd66c2d8a23ee0d18ffd74eeb304c97741))
* **dart:** add lang/dart topic ([f356638](https://github.com/eliasnorrby/dotfiles/commit/f356638fcbebddc96ee7f62cddb294a1a3678172))
* **doom:** use sync instead of refresh ([e2061d4](https://github.com/eliasnorrby/dotfiles/commit/e2061d49e3422f7976e166c04d2154d74ee362f7))
* **git:** enable rerere ([8e516fa](https://github.com/eliasnorrby/dotfiles/commit/8e516fad265625e14b869daeeb0076885cfdbb52))
* **intellij:** add mapping for Generate action ([ec96758](https://github.com/eliasnorrby/dotfiles/commit/ec96758dd3187329060315f77126b149806515ef))
* **java:** add gradle to deps ([ccf46e8](https://github.com/eliasnorrby/dotfiles/commit/ccf46e8b6b400bfc0831808ba6ade50720163a9a))
* **java:** bump JDK13 to JDK14 ([baf9b06](https://github.com/eliasnorrby/dotfiles/commit/baf9b06735f6195e3ef126fad13ede49533b64ef))
* **java:** move java from casks to formulae ([4dd4fa0](https://github.com/eliasnorrby/dotfiles/commit/4dd4fa03951f543e6a4740b36a1a34b7c7c9e6ab))
* **java:** update Java 14 JDK ([dd36511](https://github.com/eliasnorrby/dotfiles/commit/dd36511a505cdeee1523a0d424090e8b79a365f0))
* **keyboard:** map ESC to ` on GK68XS ([275a41d](https://github.com/eliasnorrby/dotfiles/commit/275a41d595a4fb98175abcd6122e32b01aeb7b3e))
* **macos:** customize dock using defaults ([349031d](https://github.com/eliasnorrby/dotfiles/commit/349031d8f53cc5a19b5da707ed7e5f35625ee27c))
* **provision:** ignore brew errors in playbook ([5815a06](https://github.com/eliasnorrby/dotfiles/commit/5815a065c5ac1ccd4c833f5b382b6fa68b2dc8e5))
* **provision:** ignore errors on gem install ([76795e6](https://github.com/eliasnorrby/dotfiles/commit/76795e6999fe801b43455233e9dbe43c789121f4))
* **provision:** only allow brew cask failures ([cfb8a36](https://github.com/eliasnorrby/dotfiles/commit/cfb8a36806d3853765937e4b921ef1a384aab3b0))
* **ruby:** update gem path ([2972c6c](https://github.com/eliasnorrby/dotfiles/commit/2972c6cff9c615c692fbd336ea2fc286b85035e7))
* **setup:** add new setup script ([984ad34](https://github.com/eliasnorrby/dotfiles/commit/984ad34d03f4421a30df6aa64ac5a5717ef75839))
* **setup:** update instructions and defaults ([686a23f](https://github.com/eliasnorrby/dotfiles/commit/686a23f40491a63989ce49e2689e77210619961d))
* **update:** update coc-nvim extensions ([9ad4a79](https://github.com/eliasnorrby/dotfiles/commit/9ad4a7967858043a1d4d1daf9ff9bf6e5c206bcd))
* **vim:** add coc-flutter to coc-extensions ([0daf76e](https://github.com/eliasnorrby/dotfiles/commit/0daf76ef9c3fcdc8c5653076fc4fc8a4dde6b771))
* **vim:** add css & docker language support ([ce42b40](https://github.com/eliasnorrby/dotfiles/commit/ce42b40ed652b46f336a52510fd5ef26ecaae596))


* feat!: remove bootstrap.sh ([aace45b](https://github.com/eliasnorrby/dotfiles/commit/aace45b65cb2e41f03596e1461c5c496995dc019))


### BREAKING CHANGES

* Remove bootstrap.sh, to be superseded by setup.sh. I'm
giving up on trying to install homebrew using ansible. setup.sh does all
the same things, but installs homebrew using the regular install script
first in order to acquire the versions of python3 and openssl needed to
properly run ansible-galaxy.

# [2.3.0](https://github.com/eliasnorrby/dotfiles/compare/v2.2.0...v2.3.0) (2020-08-31)


### Bug Fixes

* **deps:** update gh brew dependencies ([ad22525](https://github.com/eliasnorrby/dotfiles/commit/ad22525019bb6c11f81c68aebae3201290d54183))
* **fonts:** update roboto mono font name ([21bf448](https://github.com/eliasnorrby/dotfiles/commit/21bf4486c7123dfb4be267b924265b809447b3e9))
* **fonts:** update sauce code pro font name ([c3d9f31](https://github.com/eliasnorrby/dotfiles/commit/c3d9f31915cbaba7a2ee842e7a44e085e58bfd5b))


### Features

* **bash:** add shfmt and shellcheck ([832d242](https://github.com/eliasnorrby/dotfiles/commit/832d242c00567c024d7a788f499802a783aef12e))
* **bash:** add shfmt to editorconfig ([c9a9fd3](https://github.com/eliasnorrby/dotfiles/commit/c9a9fd36bce4061956c2d95a2713b825cf87809e))
* **editorconfig:** use tabs to indent go ([f6cc328](https://github.com/eliasnorrby/dotfiles/commit/f6cc328d77a2e4298da9bf69a2cb746b30f2d4ef))
* **keyboard:** add mappings for the GK68XS ([f2d69eb](https://github.com/eliasnorrby/dotfiles/commit/f2d69ebae15950715624a82774977baf6cfc45bb))
* **keyboard:** add mappings for wireless GK68XS ([72e0c59](https://github.com/eliasnorrby/dotfiles/commit/72e0c592d4193409c8ee1f83c2c03a4efdbb26b4))
* **keyboard:** extend tmux pane range to 8 ([ec23fdf](https://github.com/eliasnorrby/dotfiles/commit/ec23fdfe5598a698d8e37b7be36bb86bf0f49319))
* **keyboard:** remove the backspace disable ([3fe3d18](https://github.com/eliasnorrby/dotfiles/commit/3fe3d18481da34901d9d1a404e8f4015a467d4e6))
* **scripts:** format and solve linting issues ([9839dce](https://github.com/eliasnorrby/dotfiles/commit/9839dce61559e4075e9a318ae7109f0536713710))
* **vim:** add coc-diagnostic ([5cc41f7](https://github.com/eliasnorrby/dotfiles/commit/5cc41f7c5076411de2598df207eb576fd16a4fe5))

# [2.2.0](https://github.com/eliasnorrby/dotfiles/compare/v2.1.0...v2.2.0) (2020-07-28)


### Bug Fixes

* **base:** update font cask name ([61d4b04](https://github.com/eliasnorrby/dotfiles/commit/61d4b04a5b557c525c4dc6dc2d84d2eb99ec38e3))


### Features

* **alacritty:** bind alt-a & alt-d ([bc93fd8](https://github.com/eliasnorrby/dotfiles/commit/bc93fd877b8b0a97959ae1cf21c4cc597711e228))
* **alacritty:** disable transparency ([235d5de](https://github.com/eliasnorrby/dotfiles/commit/235d5de8a3580cfd70079af1208af2011a3e1979))
* **fzf:** sort matches in fuzzy project search ([fe2e2bd](https://github.com/eliasnorrby/dotfiles/commit/fe2e2bdc14201cb5d794dce08d6f13d8ba2d80ec))
* **scripts:** launch quick look from command line ([70c81bb](https://github.com/eliasnorrby/dotfiles/commit/70c81bb3f813163524460efbdb90ea4de8ea8323))
* **tmux:** make the active pane darker ([56bb7b2](https://github.com/eliasnorrby/dotfiles/commit/56bb7b200b52f8fa8387b4cd256ace1437fc3641))
* **vim:** add binding for word search in project ([49001b5](https://github.com/eliasnorrby/dotfiles/commit/49001b557065e7a12849ee61c8c66117788839e7))
* **vim:** add coc-go extension ([816baf5](https://github.com/eliasnorrby/dotfiles/commit/816baf578c7311b98689e3092e46d41214d58111))
* **vim:** add ctrl-a fzf binding ([3d1b76a](https://github.com/eliasnorrby/dotfiles/commit/3d1b76a88dc203b8450ecc64981700a4509dd5e2))
* **vim:** add vimwiki and goyo ([e3d7271](https://github.com/eliasnorrby/dotfiles/commit/e3d727181bf3609d3f7235c775f2f76d3766a1e0))
* **vim:** open qf window on project word search ([9fcecd4](https://github.com/eliasnorrby/dotfiles/commit/9fcecd4ee804964eb359522113765d461a690259))
* add git-messenger ([2cf02c2](https://github.com/eliasnorrby/dotfiles/commit/2cf02c281e08beab29e6aca3507952806e0051c9))
* **zsh:** add myip alias to get current ip ([bd6db6f](https://github.com/eliasnorrby/dotfiles/commit/bd6db6f913e6f8a264bc00c0d851802398b54fe8))

# [2.1.0](https://github.com/eliasnorrby/dotfiles/compare/v2.0.1...v2.1.0) (2020-07-01)


### Bug Fixes

* **macos:** update fira code cask name ([66ff8c7](https://github.com/eliasnorrby/dotfiles/commit/66ff8c71dd148a01d705341898ab202e875c6c64))
* **vim:** prefix CocRefresh with silent ([865edf0](https://github.com/eliasnorrby/dotfiles/commit/865edf0869ad3a2d96e7122705b51fda7e0532a1))
* **vim:** rename tasks file (.yaml -> .yml) ([f635860](https://github.com/eliasnorrby/dotfiles/commit/f6358603dd982fe63d996a13b73121c9fe7378e2))


### Features

* **git:** add glogb alias ([3b34a65](https://github.com/eliasnorrby/dotfiles/commit/3b34a653040339fa0d588a92273b6896ab2aad57))
* **git:** use pull.rebase by default ([35977de](https://github.com/eliasnorrby/dotfiles/commit/35977de1bd5916f84001c19305aa95227055b02d))
* **hammerspoon:** map W to powerpoint in app mode ([268e490](https://github.com/eliasnorrby/dotfiles/commit/268e490c7e6b528261d3ecbde4e66f2e1a03d5c3))
* **tmux:** bind C-s to fuzzy session switcher ([e49e71b](https://github.com/eliasnorrby/dotfiles/commit/e49e71b251d95166e3c271c911702d13ab528f43))
* **tmux:** open new windows using current path ([0b5d0ff](https://github.com/eliasnorrby/dotfiles/commit/0b5d0fff2907eeb00301c545c9c42178e848c241))
* **vim:** add coc-settings for vue ([9b86229](https://github.com/eliasnorrby/dotfiles/commit/9b862290318e103401566fdf607b879644806948))
* **vim:** add file outline binding ([a38e9eb](https://github.com/eliasnorrby/dotfiles/commit/a38e9eb0282eb3233092dcdaf6dfb3fcd67be0e0))
* **vim:** add Fix command for eslint ([a69220d](https://github.com/eliasnorrby/dotfiles/commit/a69220da3941892507ca01119d3919c0648553b7))
* **vim:** add package.json and .gitignore aliases ([e199406](https://github.com/eliasnorrby/dotfiles/commit/e199406bededffac88db586a87712c10ddfe2b4c))
* **vim:** add XMLFormat command ([74a3fa4](https://github.com/eliasnorrby/dotfiles/commit/74a3fa40c3fa93b6cf937280bf4fe2eeffbdaadc))
* **vim:** put coc extensions under version control ([e975bf7](https://github.com/eliasnorrby/dotfiles/commit/e975bf72150ef43499672be1568f0b61316b7d11))
* **web:** add vue cli ([26897a5](https://github.com/eliasnorrby/dotfiles/commit/26897a52fb86126d18cb3b1b12827f32707c9dbc))
* **zsh:** add alias n=fnpm ([219aa68](https://github.com/eliasnorrby/dotfiles/commit/219aa685078de9f8afbc65b06bff52d836268d70))
* **zsh:** add fuzzy project navigation ([53baac8](https://github.com/eliasnorrby/dotfiles/commit/53baac879dedb6769e2fd6cb0fa861121a2e3c21))
* **zsh:** add zle widget for fuzzy-finding npm scripts ([d133693](https://github.com/eliasnorrby/dotfiles/commit/d1336933607b29e9f71c3c119d4c423be269b5ce))

## [2.0.1](https://github.com/eliasnorrby/dotfiles/compare/v2.0.0...v2.0.1) (2020-05-29)


### Bug Fixes

* **provision:** use proper path for entire dir link ([ad09fe7](https://github.com/eliasnorrby/dotfiles/commit/ad09fe7f81eaab0fff59fe55dc4073452f0af9a1))
* **zsh:** remove subshells from lang/java/env ([3265c20](https://github.com/eliasnorrby/dotfiles/commit/3265c20a23c4f4144a49e2110ad6c1eea001c87e))

# [2.0.0](https://github.com/eliasnorrby/dotfiles/compare/v1.4.0...v2.0.0) (2020-04-23)


### Bug Fixes

* **fonts:** rename sourcecodepro nerd font ([b0fb15c](https://github.com/eliasnorrby/dotfiles/commit/b0fb15c863405d94f24cac4fed7c84e49f56abe4)), closes [Homebrew/homebrew-cask-fonts#1992](https://github.com/Homebrew/homebrew-cask-fonts/issues/1992)
* **provision:** make topic_tasks default to [] ([615173d](https://github.com/eliasnorrby/dotfiles/commit/615173d81a55d02f28db79a17829a5417765e2c7))
* **provision:** only do brew tasks if lists have items ([6e70efe](https://github.com/eliasnorrby/dotfiles/commit/6e70efe8fec7b7ae0722cad8e4f338bd69d884eb))
* **provision:** properly filter topic tasks based ([200151c](https://github.com/eliasnorrby/dotfiles/commit/200151cb17c3e0b004c3fd60038448b889e48188))
* **tmux:** make clipboard work again ([13d7b60](https://github.com/eliasnorrby/dotfiles/commit/13d7b602666d6b553ef6d3b049ce737969d52252))


### Code Refactoring

* **provision:** revamp topic_tasks ([6955cf7](https://github.com/eliasnorrby/dotfiles/commit/6955cf7ee1f0b85fff4b68a5b27648e488261787)), closes [#20](https://github.com/eliasnorrby/dotfiles/issues/20)


### Features

* **editor:** add intellij topic ([5d9157d](https://github.com/eliasnorrby/dotfiles/commit/5d9157d14e888f94b4f3dea9ed80a5b3b908d3e0))
* **editor:** add settings to vscode topic ([a82638d](https://github.com/eliasnorrby/dotfiles/commit/a82638d2a7cda4c14f61d3bc57cbe9bc84e4a1b0))
* **intellij:** add easymotion ([ad0f64c](https://github.com/eliasnorrby/dotfiles/commit/ad0f64cae498be3d85c15d660dbe83a09d7a7c5d))
* **intellij:** add keybinding for git blame ([5dd5f47](https://github.com/eliasnorrby/dotfiles/commit/5dd5f47ffe754a6103c4d64ba57b83f07f04a005))
* **intellij:** add keybinding for moving statements ([a4715d1](https://github.com/eliasnorrby/dotfiles/commit/a4715d198a16c6800b5ea9d4c3060b485cc5a54b))
* **intellij:** add keybindings for debugging ([0d718cf](https://github.com/eliasnorrby/dotfiles/commit/0d718cfce4425647cf16dfc55106c3a20312c51a))
* **karabiner:** add mappings for Ducky One 2 mini ([d8f75e0](https://github.com/eliasnorrby/dotfiles/commit/d8f75e054d34d4d34f898a2e5c9d47a9eea299ff))
* **keyboard:** add backspace toggle ([01f6a94](https://github.com/eliasnorrby/dotfiles/commit/01f6a94c0f44c5c876968caf2fce86d02379d77f))
* **prov:** add option to link entire topic dir ([5a9396e](https://github.com/eliasnorrby/dotfiles/commit/5a9396eec9bbbaaf7e6b5feded87232ff00d910c))
* **provision:** add 'setup_homebrew' tag ([60de319](https://github.com/eliasnorrby/dotfiles/commit/60de319ab9d30567b13727997848a62b2bb8a4b4))
* **provision:** add env var config to bootstrap ([f49e63f](https://github.com/eliasnorrby/dotfiles/commit/f49e63f1b2167a4190a8e701381f63abbbe87638))
* **provision:** add tags to post_provision ([5f578f7](https://github.com/eliasnorrby/dotfiles/commit/5f578f7399aa74dccaf1a0a96e77170c117e7169))
* **vscode:** add install script for plugins ([d970d55](https://github.com/eliasnorrby/dotfiles/commit/d970d55283c27e14bfac19f72a7c47c6485ef48f))


### BREAKING CHANGES

* **provision:** removes the 'do_post_provision' tag.

Tasks kept in `topic.tasks.yaml` files, previously known as
'post_provision_tasks' are now refered to as 'topic_tasks'. They are
executed immediately after the files are sourced, i.e. in the
eliasnorrby/dotfiles role, rather than as the last step of the playbook.

Tasks are only run if their corresponding topic is enabled. The check
for this is rather cumbersome, but is the best I could find at this
time.

```
 # breaks if shell/zsh is undefined
when: topics.shell.zsh.state == "present"
 # requires installing jmespath
when: topics | json_query('shell.zsh.state') == "present"
 # works
when:
  - topics.shell.zsh is defined
  - topics.shell.zsh.state == "present"
```

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
