hl.on('hyprland.start', function()
  hl.exec_cmd('hyprpaper')
  hl.exec_cmd('hypridle')
  hl.exec_cmd('waybar')
  -- Through its unit: swaync is D-Bus activated, so an exec'd copy races
  -- the activation and the unit fails at every login
  hl.exec_cmd('systemctl --user start swaync')
  hl.exec_cmd('systembus-notify') -- earlyoom notifications
  hl.exec_cmd('playerctld daemon') -- track most recently active MPRIS player

  hl.exec_cmd('systemctl --user start hyprpolkitagent')

  hl.exec_cmd('dropbox')

  hl.exec_cmd('~/.local/bin/tmux_set_env')

  hl.exec_cmd('~/.dotfiles/wm/gtk/gsettings.sh')

  hl.exec_cmd('wl-paste --type text --watch cliphist store')
  hl.exec_cmd('wl-paste --type image --watch cliphist store')

  -- Re-apply this session's keyboard layout on start...
  hl.exec_cmd('switch_layout sync')
end)

-- ...and on every reload
hl.on('config.reloaded', function()
  hl.exec_cmd('switch_layout sync')
end)
