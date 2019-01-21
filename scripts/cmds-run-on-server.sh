# Installing zsh
sudo apt-get install zsh
chsh -s `which zsh`

# Installing fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
# Results in different zplug home than on mac...

# VIM - badwolf colors, surround plugins
## vim surround
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/surround.git
vim -u NONE -c "helptags surround/doc" -c q

## vim commentary
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/commentary.git
vim -u NONE -c "helptags commentary/doc" -c q

## vim repeat
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/repeat.git

## badwolf scheme
# copy colors folder to ~/.vim

# Dotfiles
# Just clone private repo, run setup_symlinks.sh

# Nerd font
# Not needed?? :o

