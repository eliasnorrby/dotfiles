module.exports = {
  dotfiles: process.env.DOTFILES || "~/.dotfiles",
  rootconfig:
    process.env.DOTFILES + "/" + "root.config.yml" ||
    "~/.dotfiles/root.config.yml",
  playbook:
    process.env.DOTFILES_PLAYBOOK || "~/.dotfiles/_provision/playbook.yml"
};
