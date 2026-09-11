alias vim=nvim
alias v=nvim
alias vf="nvim +'Telescope find_files'"
alias vp='nvim package.json'
alias vg='nvim .gitignore'
alias vlog='nvim +GV'
# Open vim and land directly in a sidekick claude (:Claude is defined in the
# sidekick plugin spec)
alias vc='nvim +Claude'
# ClaudeCodeContinue came from the retired claude-code.nvim plugin; sidekick
# has no --continue entrypoint (yet)
# alias vcc='nvim +ClaudeCodeContinue'
# Claude in a plain fullscreen terminal buffer, no sidekick: vim motions over
# the transcript via normal mode, nothing else
alias V='nvim "+terminal claude" +startinsert'
