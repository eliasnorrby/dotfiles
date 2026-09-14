# Memos

Things I've worked on but keep forgetting to use.

## Tmux

| Shortcut | Action                       |
| -------- | ---------------------------- |
|   + G   | Browse to any repo           |
|   + k   | Shell popup                  |
|   + M   | Matrix screensaver           |
|   + C-p | Create pull request popup    |
|   + S   | Runner script in append mode |
|   + n   | Go to next alert             |

## Vim

| Shortcut   | Action                         |
| ---------- | ------------------------------ |
| <leader>rl | Move argument right            |
| <leader>rh | Move argument left             |
| <C-f>      | Fuzzy filter live grep results |

## Pacman / yay

| Command                | Action                                          |
| ---------------------- | ----------------------------------------------- |
| sudo pacman -Syu       | Update repo packages (run before yay -Sua)      |
| yay -Sua               | Update AUR packages only                        |
| yay -S <pkg>           | Install (repo or AUR); no sudo, it escalates    |
| sudo pacman -Rns <pkg> | Remove pkg, orphaned deps and config backups    |
| pacman -Qi <pkg>       | Show info: version, provides, conflicts         |
| pacman -Qo <path>      | Which package owns a file                       |
| pacman -Fy; pacman -F <file> | Find repo package providing a file        |
| pacman -Qdt            | List orphaned deps (remove: pacman -Rns $(...)) |
| pacman -Qm             | List foreign (AUR) packages                     |
| pacman -Qe             | List explicitly installed packages              |
| yay -Ss <term>         | Search repos and AUR                            |
| yay -Sc                | Clean package caches                            |
