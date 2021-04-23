# [5.0.0](https://github.com/eliasnorrby/dotfiles/compare/v4.0.0...v5.0.0) (2021-04-23)


### Bug Fixes

* **macos:** run brew without coreutils ([aabff0c](https://github.com/eliasnorrby/dotfiles/commit/aabff0c9353a76f9e4b14fee9314423105567707))
* **tmux:** update z binding ([16731bd](https://github.com/eliasnorrby/dotfiles/commit/16731bdb546d3e646c57acce2ee0c6adb2d46df1))
* **zsh:** add _os conditional around compgen ([67afba8](https://github.com/eliasnorrby/dotfiles/commit/67afba845950bcb5fd381d85b3f0e4944254c5d4))
* **zsh:** add --multi flag before --preview ([c5b6ab4](https://github.com/eliasnorrby/dotfiles/commit/c5b6ab45a5316930bb54235556ee421f27add711))
* **zsh:** handle local scripts with man_widget ([612cbcf](https://github.com/eliasnorrby/dotfiles/commit/612cbcfbf7997ec0abdb792cb04c60ae75e41cf5))
* **zsh:** small improvements to man_widget ([64ae48c](https://github.com/eliasnorrby/dotfiles/commit/64ae48c3e93951a3e45b26b222ff12f2875df945))


### deps

* install ansible using brew/pacman ([1d1a509](https://github.com/eliasnorrby/dotfiles/commit/1d1a5093b9c5354966a92b1e610ac21d9091bf8d))


### Features

* **emacs:** add ~/work to projects path ([c84923e](https://github.com/eliasnorrby/dotfiles/commit/c84923ec0a0df27e8af20ae2c081733de4f10a05))
* **git:** add config-notes with githooks path ([b874029](https://github.com/eliasnorrby/dotfiles/commit/b87402908413e759e23ec295b6f0d111f1c59d00))
* **git:** add config-work ([58ca78d](https://github.com/eliasnorrby/dotfiles/commit/58ca78d302bea8833a84d9cc360bb7662e07a46d))
* **git:** add glogr alias ([b265132](https://github.com/eliasnorrby/dotfiles/commit/b265132cea3ad94d7ff2e169b26ed6b6f4b1265c))
* **git:** update git lg alias ([dee3d83](https://github.com/eliasnorrby/dotfiles/commit/dee3d834da22a784841311ff852502ab1cd5065b))
* **notes:** add notes topic ([878154f](https://github.com/eliasnorrby/dotfiles/commit/878154f7ad794430813ceef481a5f3dcd0eac671))
* **scripts:** add merge-dependabot-prs.sh ([b032bc8](https://github.com/eliasnorrby/dotfiles/commit/b032bc8f398d8d33ffe88cbc0820b0dd24269858))
* **scripts:** recognize --help ([4a41d94](https://github.com/eliasnorrby/dotfiles/commit/4a41d942f1ab4738fcdf3e22d6ef3385c4ce7636))
* **tmux:** add binding for new-window with navigation ([b93fb24](https://github.com/eliasnorrby/dotfiles/commit/b93fb24f5a3a3faaca04c2c5274a19a9e759bc0c))
* **tmux:** add notes keybind ([a15d950](https://github.com/eliasnorrby/dotfiles/commit/a15d950c6e9ccd833c85bf5d528e8afe2b1438fe))
* **tmux:** use empty status-left ([1a194ea](https://github.com/eliasnorrby/dotfiles/commit/1a194ea3f3ffbcc02319fbf9ac75b884ca937716))
* **vim:** add mappings for hunk diff & revert ([6c3b6d0](https://github.com/eliasnorrby/dotfiles/commit/6c3b6d0cd61588e73acbccb1519fd0b1d60e5420))
* **vim:** disable emmet-vim ([c90d829](https://github.com/eliasnorrby/dotfiles/commit/c90d829864fb3f1776211e8076b60e2a720f2c00))
* **zsh:** add headers to prompts in man_widget ([1164013](https://github.com/eliasnorrby/dotfiles/commit/1164013b5bf6f72e648e8eb2617288c0b2a114ca))
* **zsh:** add man_widget ([dd8c46f](https://github.com/eliasnorrby/dotfiles/commit/dd8c46f1901add04e6f86581c0e87c40fe0285bf))
* **zsh:** allow multi selection in man_widget(complete) ([9eb200e](https://github.com/eliasnorrby/dotfiles/commit/9eb200e7f6d20adb0996f5c27f5a80e589c2be87))
* **zsh:** support arbitrary input in man_widget ([2d82709](https://github.com/eliasnorrby/dotfiles/commit/2d82709bfb46a45e305a72128474e38299942ef6))
* **zsh:** support chained commands in man_widget ([cb494da](https://github.com/eliasnorrby/dotfiles/commit/cb494dac4cd60c93ac88fa91a68c4295f316bd74))


### BREAKING CHANGES

* Avoid pip, preferring homebrew and pacman when
installing ansible. Hopefully this does not break the setup scripts.

# [4.0.0](https://github.com/eliasnorrby/dotfiles/compare/v3.0.0...v4.0.0) (2021-03-25)


### Bug Fixes

* **arch:** remove opacity digits from xresources ([82fa1b0](https://github.com/eliasnorrby/dotfiles/commit/82fa1b0dafe7b6d693e04f87ed40067b05cddda9)), closes [#dd292d3](https://github.com/eliasnorrby/dotfiles/issues/dd292d3)
* **arch:** use correct package for xinput ([c63c076](https://github.com/eliasnorrby/dotfiles/commit/c63c0761c3e72d5f2ad85ebf15608e740d285996))
* **bspwm:** update class used for tmux rule ([a4bd3a3](https://github.com/eliasnorrby/dotfiles/commit/a4bd3a3b7e4d2d1bd6449847c4d3ef4649ab820e))
* **fzf:** change binding for sort toggle ([2f0e0d0](https://github.com/eliasnorrby/dotfiles/commit/2f0e0d0d7d4567b9a2f1d7a91713928f570b856a))
* **fzf:** do not use sudo for yay ([3bfab25](https://github.com/eliasnorrby/dotfiles/commit/3bfab25cdacee04ac51f228b5718553eaa2bf7ba))
* **fzf:** fix fuzzy args on MacOS ([5a8f1a1](https://github.com/eliasnorrby/dotfiles/commit/5a8f1a147b54d2d03e1ff56de400d382d6505a4f))
* **fzf:** source keybindings depending on os ([b3be4c1](https://github.com/eliasnorrby/dotfiles/commit/b3be4c1e7d9e4a7c29bfb92d78effafed2e97d52))
* **gcloud:** eliminate subshells from env.zsh ([ae66e51](https://github.com/eliasnorrby/dotfiles/commit/ae66e512913536e634ffa76995c208d070b2fb89))
* **git:** add main to gbpurge exclusion ([55d0b79](https://github.com/eliasnorrby/dotfiles/commit/55d0b79951a2c38166c2a2b4f768680974fe1187))
* **intellij:** disable easymotion ([df4830f](https://github.com/eliasnorrby/dotfiles/commit/df4830f2cb6bc23f15414d35ecb40f170ecc8bc4))
* **intellij:** fix windowing on arch ([d497130](https://github.com/eliasnorrby/dotfiles/commit/d4971306b01fa3225baaa601f80c97efffa8cddf))
* **java:** call java version alias separately ([c3b8549](https://github.com/eliasnorrby/dotfiles/commit/c3b854984dfef90a151a85da38ab2425b6e273a4))
* **java:** move java aliases to macos block ([ba17866](https://github.com/eliasnorrby/dotfiles/commit/ba1786644ddf117cba9a7a441dd757f1c41f25f1))
* **provision:** add check to aur package install ([43efba3](https://github.com/eliasnorrby/dotfiles/commit/43efba38d2ca4b69e8e0bbd41872a313fe1cb4a1))
* **provision:** add missing gcloud key root configs ([b5999b3](https://github.com/eliasnorrby/dotfiles/commit/b5999b3285959c5a65d5d9dd180f387029d8bc01))
* **provision:** fix mktemp spelling ([ac9d1e4](https://github.com/eliasnorrby/dotfiles/commit/ac9d1e4d621e6966f541cfb974a2e2fdf647d29d))
* **provision:** remove do_defaults from setup-linux ([7a14498](https://github.com/eliasnorrby/dotfiles/commit/7a14498474243a2d79f2258da25b22e545ac6d67))
* **provision:** set npm prefix in extra-packages ([a329819](https://github.com/eliasnorrby/dotfiles/commit/a32981920edfc3e4c73aaaa40202112daa5b3b78))
* **provision:** use coc-nvim's flags on extension install ([076affe](https://github.com/eliasnorrby/dotfiles/commit/076affedf2c44ac7a5cfdc1e4d36d6399bd84823))
* **provision:** use new cask upgrade command ([bc78304](https://github.com/eliasnorrby/dotfiles/commit/bc783041226b34232bd597303d184c60c86eff89))
* **scripts:** juggle find arguments ([66350b0](https://github.com/eliasnorrby/dotfiles/commit/66350b0830ff39c3079dbece3fb11a37ac7bc3bd))
* **ssh:** add macos config file ([ab78e6e](https://github.com/eliasnorrby/dotfiles/commit/ab78e6ec3399324936774ebe0f761c5b8d404ccb))
* **tmux:** remove load average symbol ([f498251](https://github.com/eliasnorrby/dotfiles/commit/f498251f9d56cf511aa29936a094ab93ffabf625))
* **vim:** update coc eslint config key ([0d55559](https://github.com/eliasnorrby/dotfiles/commit/0d55559b4a6edb870c4a3847b0ec2152e3f81d3d))
* **work:** patch vpn settings for macos ([8080b21](https://github.com/eliasnorrby/dotfiles/commit/8080b2172212f2105757b5bf51ef3a3cabb0ac62))
* **xkb:** add shebang to setup-keybindings.sh ([c2021c9](https://github.com/eliasnorrby/dotfiles/commit/c2021c970e0eeada852d295b9c1c179739cc32a1))
* **xkb:** kill xcape before calling ([607cb94](https://github.com/eliasnorrby/dotfiles/commit/607cb94538bdc03c1eb4b54b5c26d76bc1fb7be1))


### Features

* **alacritty:** add glyph offsets on arch ([a82c501](https://github.com/eliasnorrby/dotfiles/commit/a82c50169a327cb9406e3ff0fad1db75259d7f46))
* **alacritty:** bind paste ([9b68142](https://github.com/eliasnorrby/dotfiles/commit/9b6814229cbebd7c6974b30568488838e67ad90b))
* **alacritty:** create tmux_alacritty wrapper ([622c9f1](https://github.com/eliasnorrby/dotfiles/commit/622c9f1a0d3fad77565b1d08157d01e2356a4094))
* **alacritty:** make theme setter work on all platforms ([c0ade4a](https://github.com/eliasnorrby/dotfiles/commit/c0ade4a7cd7d29fbb14c10297fb7fd6148d55db2))
* **alacritty:** make use of alacritty config imports ([6e1dc93](https://github.com/eliasnorrby/dotfiles/commit/6e1dc93aae94fd9157f43bbcf13ccc1d8b900472)), closes [#38](https://github.com/eliasnorrby/dotfiles/issues/38)
* **alacritty:** use ~ for config imports ([31dad08](https://github.com/eliasnorrby/dotfiles/commit/31dad08a6a87d163300df95b8bf09cefadf7995a)), closes [#38](https://github.com/eliasnorrby/dotfiles/issues/38)
* **alacritty:** use a brighter bright black ([0a09db3](https://github.com/eliasnorrby/dotfiles/commit/0a09db348a0cc4e9f4110d0e96ef7f3e12e0d09d))
* **alacritty:** use mononoki font ([aa384ca](https://github.com/eliasnorrby/dotfiles/commit/aa384ca82b603a35c1a0ea5716e876b54da00df5))
* **arch:** add additional keyserver ([2d5e09c](https://github.com/eliasnorrby/dotfiles/commit/2d5e09ce7e5a74bb3eea69898f1b6f14c8810dbf))
* **arch:** add focus_or_run script ([eec2ca1](https://github.com/eliasnorrby/dotfiles/commit/eec2ca14d19b6fbb488496bfe10ca8d8f76c637a))
* **arch:** add Xresources ([68358be](https://github.com/eliasnorrby/dotfiles/commit/68358beef2906a61732a30eba91852b766096475))
* **arch:** set mouse sensitivity with xinput ([c805c91](https://github.com/eliasnorrby/dotfiles/commit/c805c912bb70e9c317c084862e8add55d817e491))
* **bspwm:** launch dunst on startup ([f0736d1](https://github.com/eliasnorrby/dotfiles/commit/f0736d109599e4eacfdb70b7884e467dbc504590))
* **bspwm:** open chrome on desktop 6 ([f1015f6](https://github.com/eliasnorrby/dotfiles/commit/f1015f658e70eccf0c20837a2b620f8375e82ed4))
* **bspwm:** set active color to cyan ([3e04baa](https://github.com/eliasnorrby/dotfiles/commit/3e04baa1e4504dd73c0cdf54b4283bc646bec192))
* **cli:** conditionally link different boomrcs ([8a6c3b1](https://github.com/eliasnorrby/dotfiles/commit/8a6c3b1adbc2334947ce975e4c16315a001f3ed3))
* **dunst:** add topic config ([b6ce8de](https://github.com/eliasnorrby/dotfiles/commit/b6ce8de2c15bcafc7faf37c5a37dccf60bd04bf7))
* **dunst:** rewrite default config ([b7a8468](https://github.com/eliasnorrby/dotfiles/commit/b7a8468bb874b6f3e40817d5d986706256de6c75))
* **feh:** create topic config ([6cfba4d](https://github.com/eliasnorrby/dotfiles/commit/6cfba4d7adbfb6396a31afc220ccfca1880ccffd))
* **fzf:** add pf alias for fuzzy pacman search ([b91bb02](https://github.com/eliasnorrby/dotfiles/commit/b91bb0230827ac98ca1e6db7e41f3f784ea4be25))
* **fzf:** enlarge pacman preview window ([71f4043](https://github.com/eliasnorrby/dotfiles/commit/71f4043b09fd0b07e6ee4266ba8a674429706f0f))
* **fzf:** filter chromium's history ([941a8fe](https://github.com/eliasnorrby/dotfiles/commit/941a8fe1d40a61df1c81bdedfaf6f26b42ae15f4))
* **fzf:** remove file path completion binding ([1ca4f5c](https://github.com/eliasnorrby/dotfiles/commit/1ca4f5c7f4bede963064d735ce614f8f7219a30a))
* **fzf:** source completion ([9afad20](https://github.com/eliasnorrby/dotfiles/commit/9afad204c75aa5ac5115034e1d99e54dc13b7c8e))
* **picom:** add background blurring ([86a6a3d](https://github.com/eliasnorrby/dotfiles/commit/86a6a3d755b81c63ec1deac3268e13315b977841))
* **picom:** add shadows ([36a78c7](https://github.com/eliasnorrby/dotfiles/commit/36a78c7d798358d23e47fdb2e04477588ffcb975))
* **picom:** enable vsync ([7871c05](https://github.com/eliasnorrby/dotfiles/commit/7871c052db9e5bacc433184be598af557cdf5983))
* **picom:** experiment with fading ([59a950a](https://github.com/eliasnorrby/dotfiles/commit/59a950ac7be906b6651b2123766dd554d2b6b06f))
* **picom:** run with --experimental-backends ([d6127a3](https://github.com/eliasnorrby/dotfiles/commit/d6127a314f58da3a901def2dd1a529060c3164a7))
* **picom:** slightly reduce alacritty transparency ([e3fac8a](https://github.com/eliasnorrby/dotfiles/commit/e3fac8afbc1a486ae16e1cadf040b65a759c0703))
* **picom:** use the glx backend ([5fa0c24](https://github.com/eliasnorrby/dotfiles/commit/5fa0c24c01d22ea424b419df74446373a7cbad51))
* **polybar:** hide polybar in bspwm fullscreen ([545e44a](https://github.com/eliasnorrby/dotfiles/commit/545e44a476e9801725f2a0232130b2259ad3a251))
* **polybar:** modify example config ([95f51db](https://github.com/eliasnorrby/dotfiles/commit/95f51db53d669272d6629e9a1e3aa66d7a4b7acd))
* **polybar:** update module icons ([a6b999a](https://github.com/eliasnorrby/dotfiles/commit/a6b999a0d3f68cec74f1ba230885819147ef87c9))
* **provision:** add optional condition to links ([2c8f15f](https://github.com/eliasnorrby/dotfiles/commit/2c8f15f470bdd957c1a660dc51d94679166dafd9))
* **provision:** add rename option to topic links ([742657a](https://github.com/eliasnorrby/dotfiles/commit/742657a547d628a0036e4afc86b7521d2ed88360))
* **provision:** become for pacman ([4934760](https://github.com/eliasnorrby/dotfiles/commit/4934760de8f410159d193f034b1eb24cfda03058))
* **provision:** install ansible roles in post ([a8d9d8c](https://github.com/eliasnorrby/dotfiles/commit/a8d9d8ce13101ffdb05594bb3add7792d8b3b2dd))
* **provision:** install aur packages ([c9cae53](https://github.com/eliasnorrby/dotfiles/commit/c9cae53ea816239a68b04d68821831ef96441ecc))
* **rofi:** add topic config ([1fe4167](https://github.com/eliasnorrby/dotfiles/commit/1fe4167c0ad0842692ae720c171d794d2c091a15))
* **rofi:** launch rofi with super + space ([5085388](https://github.com/eliasnorrby/dotfiles/commit/50853886c3de08da31566483a394fe06d4ef9033))
* **rofi:** use dank mono font ([7c06945](https://github.com/eliasnorrby/dotfiles/commit/7c06945cfee7fd593a945241f30f9832637601ae))
* **sxhkd:** focus or run alacritty ([e2e6d21](https://github.com/eliasnorrby/dotfiles/commit/e2e6d21609efa0a3fa7da7636a9e4a3028049b7a))
* **sxhkd:** focus or run chromium ([040ff9c](https://github.com/eliasnorrby/dotfiles/commit/040ff9c9047e888bf6fe18d6b1de50f7e8c32eb2))
* **sxhkd:** map hyper + {1-9} to tmux windows ([254af0f](https://github.com/eliasnorrby/dotfiles/commit/254af0f45aa761a04481ab664fba71b34dff70c0))
* **tmux:** choose copy tool based on platform ([91a4d50](https://github.com/eliasnorrby/dotfiles/commit/91a4d50451b10bc53b1c00bd0456f59838037c81))
* **vim:** make cursorline light blue ([d0560cb](https://github.com/eliasnorrby/dotfiles/commit/d0560cbf449a907678c3d03887bd8f4549192614))
* **vim:** use unnamedplus for clipboard ([5cd5c30](https://github.com/eliasnorrby/dotfiles/commit/5cd5c30594fabb54633aa5baddcf4b32698e303b))
* **vscode:** conditionally set vscode_home ([93cae5f](https://github.com/eliasnorrby/dotfiles/commit/93cae5f6a1e843fa8a769b9706518316fbade4b0))
* **xkb:** add topic config ([cfa6b7f](https://github.com/eliasnorrby/dotfiles/commit/cfa6b7f62eaac002a51045b862bb3c3c51056857))
* **xkb:** map right alt to hyper key (mod3) ([0c41084](https://github.com/eliasnorrby/dotfiles/commit/0c41084c5779145250d394490868801b678a6e5b))
* **zsh:** remove '/' from WORDCHARS ([4b95c63](https://github.com/eliasnorrby/dotfiles/commit/4b95c634fdf863bd2df9f9f82d3150a1bfb26849))
* add become key to topic config ([798738f](https://github.com/eliasnorrby/dotfiles/commit/798738f969a4ea1cac7bb61494fb27428fb6961e))
* **alacritty:** use some transparency ([7e42ee5](https://github.com/eliasnorrby/dotfiles/commit/7e42ee5904bd4b6163fab8bf59a524f2a78a44b0))
* **arch:** add and autostart dropbox ([659dcd9](https://github.com/eliasnorrby/dotfiles/commit/659dcd973bf032b62b35994341507576ebe16fb2))
* **arch:** add topic base/arch ([ae6be72](https://github.com/eliasnorrby/dotfiles/commit/ae6be72b362394baeb59aa46ecbe3cd6985ef17a))
* **arch:** add topic config ([e191329](https://github.com/eliasnorrby/dotfiles/commit/e191329ceb170c82030b46c414d3935a69039d8b))
* **arch:** create wrapper script for spotify ([05faf26](https://github.com/eliasnorrby/dotfiles/commit/05faf26fdab97f0f17b319d05f6a783bd7c512bd)), closes [/github.com/baskerville/bspwm/issues/291#issuecomment-145329416](https://github.com//github.com/baskerville/bspwm/issues/291/issues/issuecomment-145329416)
* **arch:** enable kafka topic ([c213e5d](https://github.com/eliasnorrby/dotfiles/commit/c213e5d86ea81c0070f344d17af75c4172ac7555))
* **arch:** handle focus of withdrawn windows ([afe0962](https://github.com/eliasnorrby/dotfiles/commit/afe09622ce0e0712fc6aa87a79b6735d145cd78d))
* **arch:** improve focus_or_run.sh ([0546b90](https://github.com/eliasnorrby/dotfiles/commit/0546b908a3d8b9cf0e4995964da39b0127a6042f))
* **arch:** make aur buider a system user ([ec28d99](https://github.com/eliasnorrby/dotfiles/commit/ec28d99b855e8020cfa4052d2e3a7daccf6fb592))
* **bspm:** remove example config defaults ([796b3c4](https://github.com/eliasnorrby/dotfiles/commit/796b3c499876c84d0c53acc17f5000111ca731af))
* **bspwm:** add 1password desktop rule ([689eac8](https://github.com/eliasnorrby/dotfiles/commit/689eac8781ba75004d3d469717da54a293777b01))
* **bspwm:** add checks for dependencies ([47ed18e](https://github.com/eliasnorrby/dotfiles/commit/47ed18e84b0a32acb149fb1bf7c02da15430e9c5))
* **bspwm:** add desktop rule for slack ([2eed97a](https://github.com/eliasnorrby/dotfiles/commit/2eed97a2e7a23481d4446cad2f2606102f2b35b6))
* **bspwm:** add intellij desktop rule ([0b0b33e](https://github.com/eliasnorrby/dotfiles/commit/0b0b33e23db3167a74f2b52c88e30ecc78b933aa))
* **bspwm:** add topic config ([07f76be](https://github.com/eliasnorrby/dotfiles/commit/07f76bef8979ea87cd04ba39cf50a2ecda4f6bcc))
* **bspwm:** add topic wm/bspwm ([f8a6c2b](https://github.com/eliasnorrby/dotfiles/commit/f8a6c2b64a80f125c3ff495461bad79bf45a1682))
* **bspwm:** make use of multiple monitors ([f8126d4](https://github.com/eliasnorrby/dotfiles/commit/f8126d4e5e55ae3325ca4ede8f7a00abf26f8ffc))
* **bspwm:** reduce window gap to 10 ([d66c0f5](https://github.com/eliasnorrby/dotfiles/commit/d66c0f56caa1e3649472e1f219e057b0275a3cf4))
* **bspwm:** update for triple monitor setup ([16d0cfd](https://github.com/eliasnorrby/dotfiles/commit/16d0cfd4dad7472b3944cb53a16685a16e6e7bfe))
* **bspwm:** update window rules ([d2a125b](https://github.com/eliasnorrby/dotfiles/commit/d2a125b98a401d97d99ed1e23e469a64b5788072))
* **bspwmrc:** configure monitors with xrandr ([01b1ab2](https://github.com/eliasnorrby/dotfiles/commit/01b1ab21c60f649e50f56d63a0ff50a55ed259b5))
* **dotnet:** add lang/dotnet topic ([4decabc](https://github.com/eliasnorrby/dotfiles/commit/4decabcf59a474fb64ce47430482f563143170a5))
* **dunst:** only show notifications on main monitor ([9db7f7b](https://github.com/eliasnorrby/dotfiles/commit/9db7f7b6c26f74a2147c1a2f0aab346a2331eb4a))
* **emacs:** set font based on _os ([c1fa2b0](https://github.com/eliasnorrby/dotfiles/commit/c1fa2b0e4d6d22fd75f2b72e4da68e3b05e9a745))
* **fzf:** add fuzzy argument selection ([ebd53b7](https://github.com/eliasnorrby/dotfiles/commit/ebd53b748d4ed35bf97aa6db334e07f3f30916d2))
* **gcloud:** source path and completion ([4568545](https://github.com/eliasnorrby/dotfiles/commit/4568545ba62783550d413f494620473f9ad52de3))
* **git:** add gl and glnr aliases ([1f83273](https://github.com/eliasnorrby/dotfiles/commit/1f832731fe17d47d5b7ac58ca8695a009b131f03))
* **git:** add gprd function ([641cf78](https://github.com/eliasnorrby/dotfiles/commit/641cf78cf8150beba6c3eeec3360b4c4dc2eeae6))
* **git:** add grv alias ([801f574](https://github.com/eliasnorrby/dotfiles/commit/801f5744abc99e5d2b2396ad039a1d1ec1e1b210))
* **hammerspoon:** add rider app mapping ([72ecb57](https://github.com/eliasnorrby/dotfiles/commit/72ecb57fda7707c0b12b592ce9a3ed829a8bf2af))
* **hammerspoon:** add umlauts to app mode ([b7c2c04](https://github.com/eliasnorrby/dotfiles/commit/b7c2c04e5aff225d972ce3aa2f737ef153bf33f6))
* **intellij:** add compile project mapping ([b654e0c](https://github.com/eliasnorrby/dotfiles/commit/b654e0c3db64e7f022941713897c7d244d91e246))
* **intellij:** add go mapping for file outline ([bfcde52](https://github.com/eliasnorrby/dotfiles/commit/bfcde5212b3aac2797f791ca1b121bab78938404))
* **intellij:** add hide coverage mapping ([9d74f44](https://github.com/eliasnorrby/dotfiles/commit/9d74f44f32af499658366d14cc2b7c2493727804))
* **intellij:** add keybinds for navigating changes ([22aae08](https://github.com/eliasnorrby/dotfiles/commit/22aae086cd9a226c780cd2cafd6596521e86a1a6))
* **intellij:** add mapping to create class ([d5fdf21](https://github.com/eliasnorrby/dotfiles/commit/d5fdf2169bfd1cf8f426a003f6eace9aed631ad6))
* **intellij:** add mapping to insert semicolon ([bc0e519](https://github.com/eliasnorrby/dotfiles/commit/bc0e51963befc06d241891564505f464f39a1970))
* **intellij:** add mappings for hippie completion ([b651f3f](https://github.com/eliasnorrby/dotfiles/commit/b651f3f6411080465e53e95acdd17eb7e08ebc84))
* **intellij:** default to no line numbers ([f925564](https://github.com/eliasnorrby/dotfiles/commit/f925564545ff33a5810f55be825be88cc3a1be7f))
* **intellij:** harmonize ]d / ]e mappings ([66ba046](https://github.com/eliasnorrby/dotfiles/commit/66ba046911536f217a06304cdd843c950058a5ae))
* **intellij:** map double space to GotoFile ([dd77421](https://github.com/eliasnorrby/dotfiles/commit/dd774211b1446091c090f0bac597cbf933a38eff))
* **intellij:** refine line number toggles ([6adb51f](https://github.com/eliasnorrby/dotfiles/commit/6adb51fd0b8a4dc997d3a834bdd73b5e66e53a47))
* **intellij:** revamp window closing mappings ([c4272d3](https://github.com/eliasnorrby/dotfiles/commit/c4272d3caa17647665d55e4213cb0680be0467b5))
* **intellij:** sort sections alphabetically ([16acda6](https://github.com/eliasnorrby/dotfiles/commit/16acda6a303ffa4c0a21ccacab6920417d85b814))
* **intellij:** switch to intellij ultimate ([7136da5](https://github.com/eliasnorrby/dotfiles/commit/7136da52c91033afd791efd91037b7f571a9dd66))
* **intellij:** try to mimic unimpaired's ]<space> ([350c5be](https://github.com/eliasnorrby/dotfiles/commit/350c5bec27cc6c8fe66a8344b41c0cb39e8f9f80))
* **java:** rework JAVA_HOME env ([6de7264](https://github.com/eliasnorrby/dotfiles/commit/6de7264bca848735ac6157a72163a1e8770c51ce))
* **kubernetes:** add aliases.zsh ([c87e801](https://github.com/eliasnorrby/dotfiles/commit/c87e801b92d80217607413ce5776aece20607ca3))
* **macos:** add balenaetcher ([c350b2e](https://github.com/eliasnorrby/dotfiles/commit/c350b2ed65aaf7081e1a80515fd59eb23f82a937))
* **macos:** enable kafka topic ([19b6660](https://github.com/eliasnorrby/dotfiles/commit/19b66603673ef1651e258608075cac3b33c3c464))
* **node:** add npm to pacman_packages ([9e643fe](https://github.com/eliasnorrby/dotfiles/commit/9e643fe4181f454c6f031ef1ffb34628e67d3128))
* **node:** create a dir for global npm packages ([e80888d](https://github.com/eliasnorrby/dotfiles/commit/e80888dbdc77b120838d32115c3a34103bfc4d60))
* **picom:** add topic config ([1073b6a](https://github.com/eliasnorrby/dotfiles/commit/1073b6ac80d4edf3d5ab099cad3cbb099f72a14f))
* **picom:** launch picom on login ([ebbec14](https://github.com/eliasnorrby/dotfiles/commit/ebbec14af3bd5b296fe4747af5edbb0d9d40254a))
* **picom:** make emacs transparent ([a9280bd](https://github.com/eliasnorrby/dotfiles/commit/a9280bd0239657af866b19b4b258fdbce511fefd))
* **polybar:** add alsa module ([4a79612](https://github.com/eliasnorrby/dotfiles/commit/4a79612d1bdbb48801f1a460e19f0ed58a9ef094))
* **polybar:** add suspend to power menu ([c1ccbd9](https://github.com/eliasnorrby/dotfiles/commit/c1ccbd974283f270e5858d45ba00e42ff858d3fb))
* **polybar:** add topic config ([1371137](https://github.com/eliasnorrby/dotfiles/commit/137113770e4540b09275984869dd78c63bb5dc12))
* **polybar:** add topic panel/polybar ([b972739](https://github.com/eliasnorrby/dotfiles/commit/b972739d604c1c4c4868439af20dce83955e2929))
* **polybar:** add vpn modules ([ef3f6c7](https://github.com/eliasnorrby/dotfiles/commit/ef3f6c7cf44b75505f1eb2e04e41b49bc180ddf6))
* **polybar:** blacklist num lock indicator ([1a8b444](https://github.com/eliasnorrby/dotfiles/commit/1a8b444825053394fa20217cc95ffd1c64b702db))
* **polybar:** hide the tray ([88fead9](https://github.com/eliasnorrby/dotfiles/commit/88fead952034cafbf4da469bfc6d785d82427795))
* **polybar:** join vpn modules ([bbd34ad](https://github.com/eliasnorrby/dotfiles/commit/bbd34ad8ddc413dfbf012f64eb92dc90ad9b8ed2))
* **polybar:** try to make tray behave ([83657d1](https://github.com/eliasnorrby/dotfiles/commit/83657d10beb45645fb4241f055bb13ff39a1d4b6))
* **polybar:** use desktop %name% for labels ([cc48586](https://github.com/eliasnorrby/dotfiles/commit/cc485867bf79ea8063eb553021e35adf39c5c44d))
* **polybar:** use mononoki font ([14ab7a2](https://github.com/eliasnorrby/dotfiles/commit/14ab7a2607076812bad279d17e5b809ecaa6d611))
* **polybar:** use systemctl poweroff ([ff7634e](https://github.com/eliasnorrby/dotfiles/commit/ff7634e786fd891fd56c6eeb04033bec0a31c8d8))
* **provision:** add custom setup script for linux ([15230d6](https://github.com/eliasnorrby/dotfiles/commit/15230d63069bc81917cc2544b7493478a798b78f))
* **provision:** add platform check to update-all ([6090cea](https://github.com/eliasnorrby/dotfiles/commit/6090ceabcb66c70ceb305c0d1f30fdb8f04df6a2))
* **provision:** add support for pacman packages ([4538dfc](https://github.com/eliasnorrby/dotfiles/commit/4538dfc7a654a7a7b15400964f443ed27153e7bb))
* **provision:** check for executables in post-install ([1be0e93](https://github.com/eliasnorrby/dotfiles/commit/1be0e93950e077282b01f0d2ed5cbffa0d422ee0))
* **provision:** create ssh config dirs ([cd75749](https://github.com/eliasnorrby/dotfiles/commit/cd75749cd3e668e000595b11410365f7c47fc23d))
* **provision:** ensure list of dirs exist ([80b82c8](https://github.com/eliasnorrby/dotfiles/commit/80b82c80954c5ac16e1c74538b65be1662417abe))
* **provision:** install coc extensions in post ([c3a4aa6](https://github.com/eliasnorrby/dotfiles/commit/c3a4aa60873c40f1cb11c9d6dea56ea9da80c98e))
* **provision:** make setup-linux executable ([d3ee543](https://github.com/eliasnorrby/dotfiles/commit/d3ee543311fa461a7fc504cc39079e44f559d9c2))
* **scripts:** add update-remote.sh ([80823a1](https://github.com/eliasnorrby/dotfiles/commit/80823a16a34186b82d501457917c89a81d2550a4))
* **scripts:** add work to git changes dirs ([e4fc645](https://github.com/eliasnorrby/dotfiles/commit/e4fc64540fe1bd3036b9f86ddf1cb7cbcf6b9e4d))
* **shell:** remove newline from _os helper ([a031eab](https://github.com/eliasnorrby/dotfiles/commit/a031eab551a7570423755e08072a58e35f09d615))
* **ssh:** add topic config ([b57b658](https://github.com/eliasnorrby/dotfiles/commit/b57b6585ac2997cc80bdb9a12bcfe0da2cea0b18))
* **ssh:** include configs in config.d ([10e6e1a](https://github.com/eliasnorrby/dotfiles/commit/10e6e1af6b5650bc3f26fae400eede1b527f74e6))
* **ssh:** remove lifetime of unlocked keys ([af79d33](https://github.com/eliasnorrby/dotfiles/commit/af79d33a4b2f4d4ba2042beda0cbc3907f294b68))
* **ssh:** use keychain ([8ce01b6](https://github.com/eliasnorrby/dotfiles/commit/8ce01b6e555bcf4f665c2aaacadb685376d3e9d8))
* **sxhkd:** add 1password keybind ([46b64a1](https://github.com/eliasnorrby/dotfiles/commit/46b64a1d543c0c39e0b39f4791ba0348b46e1a52))
* **sxhkd:** add binding to launch konsole ([641c5e3](https://github.com/eliasnorrby/dotfiles/commit/641c5e3d5df61a0e34e81e45f0573a221b3f648b))
* **sxhkd:** add intellij keybind ([42a2e19](https://github.com/eliasnorrby/dotfiles/commit/42a2e199078127dd19cce788c6889a076d31121d))
* **sxhkd:** add slack keybind ([c370db2](https://github.com/eliasnorrby/dotfiles/commit/c370db2c67071afbb09070eeeab83c99bf06f000))
* **sxhkd:** add topic config ([f76c89b](https://github.com/eliasnorrby/dotfiles/commit/f76c89b350c2c7105c6e9a8f751395035ad6dda2))
* **sxhkd:** add topic keyboard/sxhkd ([e8f6602](https://github.com/eliasnorrby/dotfiles/commit/e8f66020088cd4dd97743007275f7f5241beefc0))
* **sxhkd:** add wallpaper swap keybind ([5b391bf](https://github.com/eliasnorrby/dotfiles/commit/5b391bf8c3e85c48b14f7937726bbfc0c34d062b))
* **sxhkd:** launch emacs with hyper + s ([347d84d](https://github.com/eliasnorrby/dotfiles/commit/347d84d29629b4782fbcfef39f2d3fe0f7769951))
* **sxhkd:** launch ranger with hyper + r ([b74fc27](https://github.com/eliasnorrby/dotfiles/commit/b74fc27cc3159e97290b1549f2de234a40c2e092))
* **sxhkd:** launch spotify with hyper + u ([6dd0847](https://github.com/eliasnorrby/dotfiles/commit/6dd08473631428437d3a3797ed0b82d7c4ad5d02))
* **sxhkd:** quit apps with super + q ([7ac3118](https://github.com/eliasnorrby/dotfiles/commit/7ac311853ffe75275698d494c8073c291ae1125d))
* **sxhkd:** use super + p to pin window ([2c47aa1](https://github.com/eliasnorrby/dotfiles/commit/2c47aa10dda776e0b2b49837b50c14158fc339bd))
* **tmux:** add binding to highlight last link ([d4de5ba](https://github.com/eliasnorrby/dotfiles/commit/d4de5ba40f82e95e548629a8bfeb4cab244ff828))
* **tmux:** add scratch and dotfiles bindings ([6906b40](https://github.com/eliasnorrby/dotfiles/commit/6906b40af71d83bafb48995e640766520a98a826))
* **tmux:** add session list to status and keybinds ([ff3518a](https://github.com/eliasnorrby/dotfiles/commit/ff3518a1a6bba8a782fea6ad8c0b7cfbc4b62fd3))
* **tmux:** disable active pane highlighting ([46d2999](https://github.com/eliasnorrby/dotfiles/commit/46d2999e699a0478182871bbe44da0224e65a089))
* **tmux:** do not use session id for switching ([e4ba48a](https://github.com/eliasnorrby/dotfiles/commit/e4ba48ae4659aa5d5d8c5f93c4646021ffd1ca09))
* **tmux:** move session prompt to keybind ([8668943](https://github.com/eliasnorrby/dotfiles/commit/866894382b1e02b46e18626c01652e8fa6614f55))
* **tmux:** relocate status elements ([0477fe6](https://github.com/eliasnorrby/dotfiles/commit/0477fe63a10150b173959945647e3923ae719428))
* **tmux:** skip the initial rename session prompt ([8fdbf62](https://github.com/eliasnorrby/dotfiles/commit/8fdbf62fb0bd53f1c1ab00d7dbaa973b3e165919))
* **vim:** add coc-groovy to coc-extensions ([4a3d3a3](https://github.com/eliasnorrby/dotfiles/commit/4a3d3a303ac926e5353965cbe05a2df7fcba4113))
* **vim:** add CursorColumn highlight ([b172cb0](https://github.com/eliasnorrby/dotfiles/commit/b172cb04094486aa7150a7492b1f3a2456a51c04))
* **vim:** add keybind to search project for selection ([dc90052](https://github.com/eliasnorrby/dotfiles/commit/dc90052e20287937cf404635eabe2baec79ec29d))
* **vim:** add keybind to toggle diff of windows ([af16609](https://github.com/eliasnorrby/dotfiles/commit/af166093d067a117aabc9597c19fa0b48a40b082))
* **vim:** add scrollbind toggle ([4142c57](https://github.com/eliasnorrby/dotfiles/commit/4142c5738535e4cef2602b7024ed58ea3478709f))
* **vim:** add tabular plugin ([ef9bb8e](https://github.com/eliasnorrby/dotfiles/commit/ef9bb8e124f0880b85fb87960c40ffe872601264))
* **vim:** add vlog alias ([a82daa6](https://github.com/eliasnorrby/dotfiles/commit/a82daa6d2b6561ec4b224ed9b3f8ab37741557fe))
* **vim:** brighten fzf's border ([8f53e36](https://github.com/eliasnorrby/dotfiles/commit/8f53e367258454e4918012067dd0590037a41e0a))
* **vim:** disable double cmdheight ([b479208](https://github.com/eliasnorrby/dotfiles/commit/b47920822e5054d9956ee2f3763561d01b2424bd))
* **vim:** enable coc-explorer file icons ([300c608](https://github.com/eliasnorrby/dotfiles/commit/300c608b01a523140f19cbfe6653925cf8dadf06))
* **vim:** map leader , to :History ([856ef05](https://github.com/eliasnorrby/dotfiles/commit/856ef05efa0494d1316016bfd99c20420f9c1bf4))
* **vim:** update project-wide search functions ([9cef954](https://github.com/eliasnorrby/dotfiles/commit/9cef954ca98c2e42799a1f4db865cb653219259e)), closes [/github.com/junegunn/fzf/issues/1109#issuecomment-339983902](https://github.com//github.com/junegunn/fzf/issues/1109/issues/issuecomment-339983902) [/github.com/junegunn/fzf.vim/issues/346#issuecomment-288483704](https://github.com//github.com/junegunn/fzf.vim/issues/346/issues/issuecomment-288483704)
* **vim:** use editorconfig for shfmt settings ([67f34a6](https://github.com/eliasnorrby/dotfiles/commit/67f34a6309011e891630858b3d3c1223ee277492)), closes [#32](https://github.com/eliasnorrby/dotfiles/issues/32)
* **vim:** use standard tabline ([f0bf112](https://github.com/eliasnorrby/dotfiles/commit/f0bf11294d3edea4b010d6b0ec312bbd92897fe4))
* **work:** add base/work topic ([41adbdd](https://github.com/eliasnorrby/dotfiles/commit/41adbddcb051728a8f6c631e9e705b2a42cbb4c6))
* **work:** add vpn connection scripts ([a7d9c89](https://github.com/eliasnorrby/dotfiles/commit/a7d9c89b59abc61ceefb154c0710151e5d986142))
* **work:** add vpn_disconnect and provision sudo ([00ff1d0](https://github.com/eliasnorrby/dotfiles/commit/00ff1d0290499b0085c28763da304e76e0c0f5cd))
* **zsh:** add chx and ns aliases ([5c754cb](https://github.com/eliasnorrby/dotfiles/commit/5c754cbdeebebd945508a693bd5391818cf4e50d))
* **zsh:** add fuzzy ascii art font picker ([90525d6](https://github.com/eliasnorrby/dotfiles/commit/90525d630ffc9f901febc94a207c2804a54bdd34))
* **zsh:** add sudoedit alias ([d74e781](https://github.com/eliasnorrby/dotfiles/commit/d74e78159f43f60e106e5a5c6cc42db7ed50c4af))
* **zsh:** only attach to tmux on macos ([e38eaac](https://github.com/eliasnorrby/dotfiles/commit/e38eaace797f4ff2109aa1b93929a2279e9421a2))
* **zsh:** only use gls on macos ([2f5969a](https://github.com/eliasnorrby/dotfiles/commit/2f5969a20040a765c8eb5974fb0fcf128e8aa061))
* **zsh:** remove . from WORDCHARS ([53ee31a](https://github.com/eliasnorrby/dotfiles/commit/53ee31a8c43dd8a87928ab20f461400d318484e6))
* **zsh:** remove line numbers from fzf preview ([a4754c9](https://github.com/eliasnorrby/dotfiles/commit/a4754c92ac1eb64f26d6e960658a3314fdb1b9d5))
* **zsh:** start ssh-agent on launch ([8181d45](https://github.com/eliasnorrby/dotfiles/commit/8181d452e6c19c0f8fb187c66f33871164dd4c5a))
* **zsh:** switch yq implementation on arch ([438f929](https://github.com/eliasnorrby/dotfiles/commit/438f929598084fd86479cb9ce30023b21c879006))
* add linux.config.yml ([c891af2](https://github.com/eliasnorrby/dotfiles/commit/c891af2074f1d392a383c48b7a4040f410ce7633))
* add pacman_packages to topics ([069ae0c](https://github.com/eliasnorrby/dotfiles/commit/069ae0cc784da257226926a8371c15ff279fec22))


* refactor!: rename root.config.yml ([c9cead7](https://github.com/eliasnorrby/dotfiles/commit/c9cead7049d455aa9f48a0e06dcbded08d953159))


### BREAKING CHANGES

* Instead of a singular root.config.yml, use
<os>.config.yml's. This will force an update to the CLI.

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
