local vars = require('config.vars')
local hyper, mainMod = vars.hyper, vars.mainMod
local opacity = vars.opacity
local window_opacity = vars.theme.window_opacity

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

-- Each app's home workspace by class, for send_home below
local homes = {}

local function rule(spec)
  if spec.workspace then
    homes[spec.match.class] = spec.workspace
  end
  hl.window_rule(spec)
end

hl.bind('SUPER + RETURN', exec(vars.terminal))
rule({ match = { class = 'kitty' }, opacity = opacity(window_opacity) })

hl.bind(hyper .. ' + T', exec('focus_or_run TmuxKitty tmux_kitty'))
rule({
  name = 'TmuxKitty',
  match = { class = 'TmuxKitty' },

  workspace = '1',
  opacity = opacity(window_opacity),
})

hl.bind(hyper .. ' + F', exec('focus_or_run HerdrKitty herdr_kitty'))
rule({
  name = 'HerdrKitty',
  match = { class = 'HerdrKitty' },

  workspace = '12',
  opacity = opacity(0.9),
})

hl.bind(hyper .. ' + R', exec('focus_or_run runner.desktop'))
rule({
  name = 'RunnerKitty',
  match = { class = 'RunnerKitty' },

  workspace = 'special:runner',
  opacity = opacity(0.9),
})

hl.bind(hyper .. ' + C', exec('focus_or_run chrome-personal.desktop'))
rule({ match = { class = 'ChromePersonal' }, workspace = '2' })

hl.bind(hyper .. ' + X', exec('focus_or_run chrome-work.desktop'))
rule({ match = { class = 'ChromeWork' }, workspace = '3' })

hl.bind(hyper .. ' + Z', exec('focus_or_run slack'))
rule({ match = { class = 'slack' }, workspace = '4', opacity = opacity(0.97) })

hl.bind(hyper .. ' + M', exec('focus_or_run teams-for-linux /opt/teams-for-linux/teams-for-linux'))
rule({ match = { class = 'teams-for-linux' }, workspace = '5', opacity = opacity(0.97) })

-- Google Meet PWA
hl.bind(hyper .. ' + A', exec('focus_or_run google-meet.desktop'))
rule({ match = { class = 'chrome-kjgfgldnnfoeklkmfkjfagphfepbbdan-Default' }, workspace = '5' })

-- Linear PWA
hl.bind(hyper .. ' + W', exec('focus_or_run linear.desktop'))
rule({ match = { class = 'chrome-bgdbmehlmdmddlgneophbcddadgknlpm-Default' }, workspace = '11' })

-- Spotify's CEF falls back to XWayland when DISPLAY is set, ignoring
-- ozone-platform=wayland flags. Unsetting DISPLAY forces native Wayland.
-- https://aur.archlinux.org/packages/spotify?O=0#comment-1066629
hl.bind(hyper .. ' + U', exec('focus_or_run spotify "env -u DISPLAY spotify"'))
rule({ match = { class = 'spotify' }, workspace = '6', opacity = opacity(0.90) })

-- Brain.fm PWA
hl.bind(hyper .. ' + B', exec('focus_or_run brain-fm.desktop'))
rule({
  match = { class = 'chrome-dcllmfmjlkpljanfegjgohmlnfipachj-Default' },
  workspace = '6',
  opacity = opacity(0.90),
})

hl.bind(hyper .. ' + N', exec('focus_or_run obsidian'))
rule({
  name = 'Obsidian',
  match = { class = 'obsidian' },

  workspace = '7',
  opacity = opacity(0.95),
})

hl.bind(hyper .. ' + V', exec('focus_or_run notion notion-app'))
rule({
  name = 'Notion',
  match = { class = 'notion' },

  workspace = '7',
  opacity = opacity(0.95),
})

hl.bind(hyper .. ' + I', exec('focus_or_run btop.desktop'))
rule({
  name = 'BtopKitty',
  match = { class = 'BtopKitty' },

  workspace = '8',
  opacity = opacity(0.9),
})

-- Claude PWA
hl.bind(hyper .. ' + Q', exec('focus_or_run claude.desktop'))
rule({
  name = 'Claude',
  match = { class = 'chrome-fmpnliohjhemenmnlpbfagaolkdacoja-Default' },

  workspace = '10',
  opacity = opacity(0.95),
})

hl.bind(hyper .. ' + P', exec('1password --quick-access'))

-- Dotfiles
hl.bind(hyper .. ' + E', exec('focus_or_run dotfiles.desktop'))
rule({
  name = 'DotfilesKitty',
  match = { class = 'DotfilesKitty' },

  workspace = '9',
  opacity = opacity(0.9),
})

-- Taskwarrior scratchpad
hl.bind('ALT + G', exec('focus_or_run taskwarrior-tui.desktop'))
hl.bind(hyper .. ' + G', exec('focus_or_run taskwarrior-tui.desktop'))
rule({
  name = 'TaskwarriorTui',
  match = { class = 'TaskwarriorTui' },

  workspace = 'special:tasks',
  float = true,
  size = { 'monitor_w*0.8', 'monitor_h*0.8' },
  center = true,
  opacity = opacity(0.9),
})

-- Scratch terminal (pinned right)
hl.bind('ALT + D', exec('focus_or_run scratch.desktop'))
hl.bind(hyper .. ' + D', exec('focus_or_run scratch.desktop'))
rule({
  name = 'ScratchKitty',
  match = { class = 'ScratchKitty' },

  workspace = 'special:scratch',
  float = true,
  size = { 'monitor_w*0.25', 'monitor_h*0.6' },
  move = { 'monitor_w*0.73', 'monitor_h*0.15' },
  opacity = opacity(0.9),
})

hl.bind(hyper .. ' + O', exec('focus_or_run obsidian-popup.desktop'))
rule({
  name = 'ObsidianPopupKitty',
  match = { class = 'ObsidianPopupKitty' },

  workspace = 'special:obsidian',
  float = true,
  size = { 'monitor_w*0.40', 'monitor_h*0.9' },
  move = { 'monitor_w*0.59', 'monitor_h*0.05' },
  opacity = opacity(0.95),
})

-- Popup terminal (vim-style command mode)
hl.bind(mainMod .. ' + semicolon', exec("kitty --class PopupKitty -o 'map escape close_window'"))
rule({
  name = 'PopupKitty',
  match = { class = 'PopupKitty' },

  float = true,
  size = { 800, 50 },
  dim_around = true,
  move = { 'monitor_w*0.5-800/2', 'monitor_h-250' },
  opacity = opacity(0.85),
  stay_focused = true,
  border_size = 2,
})

-- send window to its 'home' workspace (based on the rules above)
hl.bind('SUPER + CTRL + SHIFT + H', function()
  local window = hl.get_active_window()
  local home = window and homes[window.class]
  if not home then
    hl.exec_cmd("notify-send -u low -t 2300 'No rule found for this window'")
    return
  end
  hl.dispatch(hl.dsp.window.move({ workspace = home, follow = true }))
end)

-- tmux window select
for i = 1, 9 do
  hl.bind(hyper .. ' + ' .. i, exec('tmux select-window -t ' .. i))
end
