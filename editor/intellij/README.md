# IntelliJ IDEA

## PLUGINS
Listing them here because I don't have anywhere better to put them
- IdeaVim
- AceJump
- IdeaVim-EasyMotion
- Tab Shifter
- Material Theme UI
- Atom Material Icons
- Lombok
- Google Java Format
- macOS For All

## SETTINGS

### Keymap
* Preferences -> Keymap -> macOS For All

### To enable Spring Auto Rebuild
* Preferences -> Build, Execution, Deployment -> Compiler -> Build project
automatically
* Actions -> "Registry" -> Enable 'compiler.automake.allow.when.app.running'

### Cleaning up the UI

#### To hide Tabs
* Preferences -> Editor -> General -> Editor Tabs -> Tab placement = None
* Also easily reachable via Actions

#### To hide tool window bars
* Preferences -> Apperance & Behaviour -> Appearance -> Show tool window
bars
* Also easily reachable via Actions

#### To hide line numbers
* Preferences -> Editor -> General -> Appearance -> Show line numbers
* Also easily reachable via Actions

### Material UI Theme
* Pick Palenight (or whatever) and restart the IDE a couple of times to make it stick
* Preferences -> Appearance & Behaviour -> Material Theme:
  * Compact
    * Compact Menus
    * Compact Dropdown Lists
  * Project View
    * Custom Sidebar Height : 18
  * Other Tweaks
    * Untick 'Theme in StatusBar'

### Google Java Format
* File -> New Project Settings -> Other Settings -> google-java-format Settings : Tick the box
* Preferences -> Editor -> Code Style : Import xml settings as described [here][1].

### Disable the annoying git popup
* File -> New Project Settings -> Version Control -> Confirmation -> When files are created/deleted : Do not add/remove

### Always enable annotation processing (for lombok)
* File -> New Project Settings -> Build, Execution, Deployment -> Compiler -> Annotation Processors : Enable annotation processing

## KEYMAPS

### Toggle VIM mode

Set CMD + SHIFT + CTRL + V to toggle VIM plugin.

[1]: https://github.com/google/google-java-format#intellij-android-studio-and-other-jetbrains-ides
