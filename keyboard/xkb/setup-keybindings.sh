setxkbmap -layout 'us,se' -option 'grp:shifts_toggle'

# Swap left alt and left super (to mimic Apple keyboard layouts)
setxkbmap -option 'altwin:swap_lalt_lwin'

# Caps lock works as ctrl when held down
setxkbmap -option 'caps:ctrl_modifier'
# Caps lock is Escape
xcape -e 'Caps_Lock=Escape'
# So, hold caps lock for ctrl, tap for escape

# Modified version of this suggestion:
# https://askubuntu.com/a/794087
setxkbmap -print | \
  sed -e '/xkb_symbols/s/"[[:space:]]/+local&/' | \
  xkbcomp -I${HOME}/.config/xkb - ${DISPLAY}

# Map right alt to hyper
xmodmap -e "keycode 108 = Hyper_L"
