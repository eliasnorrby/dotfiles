-- See https://wiki.hypr.land/configuring/core/binds/ and the dispatcher
-- list at https://wiki.hypr.land/configuring/core/dispatchers/

local vars = require('config.vars')
local mainMod = vars.mainMod
local dsp = hl.dsp

local function exec(cmd)
  return dsp.exec_cmd(cmd)
end

-- Delete key: screenshot when unlocked, suspend when locked
hl.bind(
  'Delete',
  exec(
    'pgrep hyprlock && systemctl suspend || grim -g "$(slurp -d)" - | tee ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy'
  ),
  { locked = true }
)

-- Lock screen only (non-consuming, so the key still reaches apps when unlocked)
hl.bind('F12', exec('pgrep hyprlock && toggle_display_brightness'), { locked = true, non_consuming = true })
hl.bind(
  'Escape',
  exec([[pgrep hyprlock && hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })']]),
  { locked = true, non_consuming = true }
)

hl.bind(mainMod .. ' + Q', dsp.window.close())
hl.bind(mainMod .. ' + V', dsp.window.float({ action = 'toggle' }))
hl.bind('ALT + SPACE', exec(vars.menu))
hl.bind(mainMod .. ' + F', dsp.window.fullscreen({ mode = 'maximized' }))

-- Move focus with mainMod + arrow keys
for _, direction in ipairs({ 'left', 'right', 'up', 'down' }) do
  hl.bind(mainMod .. ' + ' .. direction, dsp.focus({ direction = direction }))
end

-- Toggle between two most recent windows
hl.bind(mainMod .. ' + TAB', dsp.focus({ last = true }))
hl.bind('ALT + TAB', dsp.window.cycle_next())
hl.bind('ALT + SHIFT + TAB', dsp.window.cycle_next({ next = false }))

local hjkl = { H = 'left', J = 'down', K = 'up', L = 'right' }

-- Seamless navigation between hyprland windows, tmux panes, and vim
for key, direction in pairs(hjkl) do
  hl.bind(mainMod .. ' + ' .. key, exec('navigate ' .. direction))
end

-- Move windows with mainMod + SHIFT + hjkl
for key, direction in pairs(hjkl) do
  hl.bind(mainMod .. ' + SHIFT + ' .. key, dsp.window.move({ direction = direction }))
end

-- Resize windows with mainMod + CTRL + hjkl
local resize = { H = { -40, 0 }, J = { 0, 40 }, K = { 0, -40 }, L = { 40, 0 } }
for key, delta in pairs(resize) do
  hl.bind(
    mainMod .. ' + CTRL + ' .. key,
    dsp.window.resize({ x = delta[1], y = delta[2], relative = true }),
    { repeating = true }
  )
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. ' + ' .. key, dsp.focus({ workspace = i }))
  hl.bind(mainMod .. ' + SHIFT + ' .. key, dsp.window.move({ workspace = i, follow = true }))
end

-- Media keys
hl.bind('XF86AudioRaiseVolume', exec('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'), { locked = true, repeating = true })
hl.bind('XF86AudioLowerVolume', exec('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'), { locked = true, repeating = true })
hl.bind('XF86AudioMute', exec('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'), { locked = true })
hl.bind('XF86AudioPlay', exec('playerctl play-pause'), { locked = true })
hl.bind('Page_Up', exec('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPrev', exec('playerctl previous'), { locked = true })
hl.bind('XF86AudioNext', exec('playerctl next'), { locked = true })

hl.bind(mainMod .. ' + CTRL + P', dsp.window.pin())

-- Special paste - paste URL from clipboard as a rich-text hyperlink
hl.bind(mainMod .. ' + SHIFT + P', exec('special_paste'))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. ' + mouse:272', dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. ' + mouse:273', dsp.window.resize(), { mouse = true })

-- Notifications
hl.bind(mainMod .. ' + N', exec('swaync-client --hide-latest'))
hl.bind(mainMod .. ' + SHIFT + N', exec('swaync-client --hide-all'))

-- Focus timer (notifications/focus): start a pomodoro, or end it early
hl.bind(vars.hyper .. ' + S', exec('focus toggle'))
hl.bind(mainMod .. ' + P', exec('swaync-client --toggle-panel'))

-- Keyboard layout. switch_layout also presses F14..F17 for espanso's sake
-- (see the script); swallow them so apps don't see XF86Launch5..8.
hl.bind(mainMod .. ' + SPACE', exec('switch_layout next'))
for i = 5, 8 do
  hl.bind('XF86Launch' .. i, dsp.no_op())
end

-- Point and click from the keyboard: kbptr (keyboard/wl_kbptr) says what
-- each mode does. Left Ctrl is keyd's mouse layer (keyboard/keyd), whose
-- keys arrive here as keys nothing else uses:
--   Left Ctrl tap  F18             one click, on a target in the focused window
--   + Space        F19             the click loop: on, click away, off (Escape)
--   + F            XF86LaunchA     pointer to a grid tile, to scroll there
--   + V            XF86Tools       select: drag from one target to another
--   + D            XF86Calculator  double click a target (a word)
--   + T            XF86Explorer    triple click a target (a line)
--   + S            XF86Mail        screenshot between two corners (tile, split)
--   + Escape       XF86LaunchB     end a stuck overlay
-- (+ j/k scroll, in keyd itself.)
hl.bind('XF86Launch9', exec('kbptr'))
hl.bind('F19', exec('kbptr toggle'))
hl.bind('XF86LaunchA', exec('kbptr point'))
hl.bind('XF86Tools', exec('kbptr select'))
hl.bind('XF86Calculator', exec('kbptr double'))
hl.bind('XF86Explorer', exec('kbptr triple'))
hl.bind('XF86Mail', exec('kbptr shot'))
hl.bind('XF86LaunchB', exec('kbptr kill'))

-- Lock screen
hl.bind(mainMod .. ' + CTRL + Q', exec('loginctl lock-session'))

-- Clipboard history
hl.bind('SUPER + C', exec('rofi -modi clipboard:cliphist_rofi_img -show clipboard -show-icons'))
hl.bind('SUPER + SHIFT + C', exec('cliphist list | rofi -dmenu -i -p "Delete from history" | cliphist delete'))

-- Calculator
hl.bind('SUPER + equal', exec('rofi -show calc -modi calc -no-show-match -no-sort | wl-copy'))

-- Taskwarrior quick add (bypasses active context's write filter)
hl.bind(mainMod .. ' + T', exec('task_quick_add'))

-- Voice input
hl.bind('SUPER + R', exec('hyprvoice_toggle'))
hl.bind('SUPER + SHIFT + R', exec('hyprvoice_toggle cancel'))

-- Tapping SUPER alone. Since 0.57 a release bind only checks the mods held
-- when SUPER_L went down, so a SUPER_L released mid-chord fires too (keyd's
-- hyper layer presses Super first, then lets it go before sending an
-- arrow). So run only if nothing else was pressed between SUPER_L down and
-- up: the key just released is also the last one pressed.
local lastPressed, lastReleased
hl.on('input.keyboard.key', function(keycode, _, state)
  if state == 1 then
    lastPressed = keycode
  elseif state == 0 then
    lastReleased = keycode
  end
end)

local function onTap(cmd)
  return function()
    if lastPressed == lastReleased then
      hl.exec_cmd(cmd)
    end
  end
end

hl.bind(
  'SUPER + SUPER_L',
  onTap(
    'pgrep wcmd || kitty -o cursor_trail=0 --class WhichCmd -e wcmd --config ~/.config/hypr/commands.yml build --exec'
  ),
  { release = true }
)
hl.window_rule({
  name = 'WhichCmd',
  match = { class = 'WhichCmd' },

  float = true,
  size = { 1000, 250 },
  dim_around = true,
  move = { 'monitor_w*0.5-1000/2', 'monitor_h*0.75' },
  opacity = vars.opacity(0.9),
  stay_focused = true,
  border_size = 3,
})

hl.bind(
  'CTRL + SUPER + SUPER_L',
  onTap(
    "tmux display-popup -E -b rounded -y P -w 45% -h 12 -T ' which-cmd ' 'wcmd --config ~/.config/tmux/commands.yml build --exec'"
  ),
  { release = true }
)

-- Delete previous word (Ctrl+W -> Ctrl+Backspace, passthrough in terminals)
hl.bind('CTRL + W', exec('delete_prev_word'))
-- Close tab: deliver a real Ctrl+W straight to the client (bypasses the bind
-- above; no virtual keyboard involved, so the layout indicator is untouched)
hl.bind(mainMod .. ' + W', dsp.send_shortcut({ mods = 'CTRL', key = 'W' }))
