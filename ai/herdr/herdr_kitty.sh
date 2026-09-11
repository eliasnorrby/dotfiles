#!/bin/sh

# Dedicated kitty window for herdr, mirroring tmux_kitty. The class is what
# focus_or_run matches on ($hyper+H).
kitty --class HerdrKitty zsh -i -c herdr &
