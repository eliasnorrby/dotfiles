if [[ $(_os) == macos ]]; then
  alias emacs='emacs -nw'

  e() { # Emacs version of v
    if pgrep Emacs 2>&1 >/dev/null; then
      emacsclient -n $@
    else
      echo "Emacs is not running"
      return 1
      # /Applications/Emacs.app/Contents/MacOS/Emacs $@ &
    fi
  }
else
  alias e='emacsclient -n'
fi
