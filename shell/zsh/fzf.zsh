# Key bindings & completion
# ------------
if [[ "$(_os)" == "macos" ]] ; then
  source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
else
  source "/usr/share/fzf/key-bindings.zsh"
  source "/usr/share/fzf/completion.zsh"
fi

# Customization
# -------------
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --bind 'ctrl-y:execute-silent(echo -n {2..} | $(get_copy_cmd))+abort' --header 'Press CTRL-Y to copy command into clipboard'"

if _is_callable fd ; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
fi

_is_callable bat && export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"
_is_callable tree && export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

export FZF_DEFAULT_OPTS='
  --prompt "λ: "
  --color fg:7,bg:-1,hl:3,fg+:15,bg+:-1,hl+:4
  --color info:7,prompt:4,spinner:6,pointer:4,marker:4,gutter:-1
  --bind  ctrl-a:select-all
'

export FZF_TMUX_OPTS='-p 70%,70%'

## FZF FUNCTIONS ##
# -----------------
# Inspired by (read: copy-pasted from) the Jarvis dotfiles (ctaylo21/jarvis)
# Source: https://github.com/ctaylo21/jarvis

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
# Note: duplicated by ^R mapping
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fgb [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fuzzy grep via rg and open in vim with line number
fgr() {
  local file
  local line

  read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     nvim $file +$line
  fi
}

# select from previous long-ish arguments
fargs() {
  local args
  history -500 | cut -c 8- | sed 's/ /\n/g' | sed '/^.\{0,5\}$/d' | sort | uniq | fzf_tmux --reverse
}

fzf-args-widget() { local result=$(fargs | join-lines); zle reset-prompt; LBUFFER+=$result }
zle -N fzf-args-widget
bindkey ',a' fzf-args-widget

# FZF heart NPM?
fnpm() {
  local repo_root package_dir script
  package_dir="$(pwd)"
  if [[ ! -f package.json ]] ; then
    repo_root="$(git rev-parse --show-toplevel)"
    if [[ ! -f "${repo_root}/package.json" ]] ; then
      return
    else
      package_dir="$repo_root"
    fi
  fi
  script=$( jq -r '.scripts' "${package_dir}/package.json" | jq 'keys[]' | sed 's/"//g' | package_dir="$package_dir" fzf_tmux --ansi --reverse \
    --preview 'jq -r ".scripts[\"$(echo {})\"]" "'"${package_dir}"'/package.json" | bat -l sh --color always --decorations never')
  [ -z "$script" ] && return
  npm run $script
}

npm-widget() {
  local repo_root package_dir script runner
  package_dir="$(pwd)"
  repo_root="$(git rev-parse --show-toplevel)"
  if [[ ! -f package.json ]] ; then
    if [[ ! -f "${repo_root}/package.json" ]] ; then
      return
    else
      package_dir="$repo_root"
    fi
  fi
  if [[ -f yarn.lock ]] \
    || [[ -f "${package_dir}/yarn.lock" ]] \
    || [[ -f "${repo_root}/yarn.lock" ]]; then
    runner=yarn
  elif [[ -f pnpm-lock.yaml ]] \
    || [[ -f "${package_dir}/pnpm-lock.yaml" ]] \
    || [[ -f "${repo_root}/pnpm-lock.yaml" ]]; then
    runner=pnpm
  else
    runner="npm run"
  fi
  script=$( jq -r '.scripts' "${package_dir}/package.json" | jq 'keys[]' | sed 's/"//g' | package_dir="$package_dir" fzf_tmux --ansi --reverse \
    --preview 'jq -r ".scripts[\"$(echo {})\"]" "'"${package_dir}"'/package.json" | bat -l sh --color always --decorations never')
  zle reset-prompt
  [ -z "$script" ] && return
  BUFFER="${runner} ${script}"
  zle end-of-line
}

zle -N npm-widget
bindkey '^N' npm-widget

fartii() {
  local string fonts art
  string="$@"
  if ! _is_callable artii ; then
    echo "'artii' not found"
    return
  fi
  fonts=$(artii -l | sed -e '1,5d' -e '/^$/,$d')
  font=$(echo "$fonts" | fzf --border --ansi --reverse --preview-window=down:80% --preview "artii -f {} $string")
  if [ -n "$font" ] ; then
    artii -f "$font" "$string" | copy_cmd
    echo "Copied to clipboard"
  fi
}

# GIT heart FZF
# Copied from junegunn's dotfiles and/or this post:
# https://junegunn.kr/2016/07/fzf-git
# -------------
# FIXME: key-bindings

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

fzf_tmux() {
  fzf-tmux "$FZF_TMUX_OPTS" "$@"
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf_tmux -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1 -c -1"

# I use gg instead of gh because <c-h> is taken by tmux
gg() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf_tmux -p "90%,70%" --ansi --no-sort --reverse --multi \
    --bind 'ctrl-n:toggle-sort' \
    --bind "ctrl-y:execute-silent($_gitLogLineToHash | $(get_copy_cmd))+abort" \
    --header 'Press CTRL-N to toggle sort, CTRL-Y to yank' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

gz() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

bind-git-helper() {
  local c
  for c in $@; do
    eval "fzf-g$c-widget() { local result=\$(g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}
bind-git-helper f b t r g z
unset -f bind-git-helper

# More git love

if command -v gh > /dev/null 2>&1 ; then
  gpr() {
    gh pr list | column -s $'\t' -t | fzf | awk '{print $1}' | xargs gh pr checkout
  }
fi

# FZF Project search

projects() {
  local query=$1
  local DIR_LIST=(
    "${HOME}/dev"
    "${HOME}/learn"
    "${HOME}/work"
  )

  local REPOS
  for dir in ${DIR_LIST[@]}; do
    local dir_repos=$(find ${dir} -maxdepth 3 -name ".git" -type d | sed 's/\/.git$//')
    if [[ -z "${dir_repos}" ]]; then
      continue
    fi
    REPOS="${REPOS}\n${dir_repos}"
  done

  if [[ -n "$query" ]]; then
    local TARGET="$(echo -e "$REPOS" | fzf --filter "$query" | head -1)"
    if [[ -n "$TARGET" ]] ; then
      cd "${TARGET}"
    fi
  else
    # # Preview with bat or ls
    # local target="$(echo "$REPOS" |
    #   sed "s#$HOME##" |
    #   fzf --border \
    #   --preview "[ -f ${HOME}{}/README.md ] \
    #   && bat --color=always ${HOME}{}/README.md \
    #   || ls --color=always ${HOME}{}")"
    # echo $PWD

    # # Preview with tree
    local TARGET="$(echo -e "$REPOS" |
      sed "s#$HOME##" |
      fzf --border --tac \
      --preview "tree -C -I node_modules -L 3 ${HOME}{}")"

    if [[ -n "$TARGET" ]] ; then
      cd "${HOME}/${TARGET}"
    fi
  fi

}

alias z=projects

apps() {
  cd "$(git rev-parse --show-toplevel)" || return 1
  local query=$1
  local DIR_LIST=(
    "${PWD}/apps"
    "${PWD}/packages"
    "${PWD}/workspaces"
  )

  for dir in ${DIR_LIST[@]}; do
    if [[ ! -d "${dir}" ]]; then
      continue
    fi
    local APPS="${APPS}\n$(find ${dir} -maxdepth 1 -mindepth 1 -type d)"
  done

  if [[ -n "$query" ]]; then
    local TARGET="$(echo -e "$APPS" | fzf --filter "$query" | head -1)"
    if [[ -n "$TARGET" ]] ; then
      cd "${TARGET}"
    fi
  else
    # # Preview with tree
    local TARGET="$(echo -e "$APPS" |
      sed "s#$PWD##" |
      fzf --border --tac \
      --preview "tree -C -I node_modules -L 3 {}")"

    if [[ -n "$TARGET" ]] ; then
      cd "${PWD}/${TARGET}"
    fi
  fi

}

alias a=apps

if [[ "$(_os)" == "arch" ]] ; then
  # FZF Pacman search
  ialias pf="pacman -Slq | fzf --multi --preview-window=right:70% --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
  ialias yf="yay -Slq | fzf --multi --preview-window=right:70% --preview 'yay -Si {1}' | xargs -ro yay -S"
fi

# Fuzzy chrome history
function chrome() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [[ "$(_os)" == macos ]]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/chromium/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
      from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

