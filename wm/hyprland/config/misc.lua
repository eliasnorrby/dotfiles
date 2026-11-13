hl.env('XCURSOR_THEME', 'catppuccin-macchiato-dark-cursors')
hl.env('XCURSOR_SIZE', '24')
hl.env('HYPRCURSOR_THEME', 'catppuccin-macchiato-dark-cursors')
hl.env('HYPRCURSOR_SIZE', '24')
hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'wayland')
hl.env('GTK_THEME', 'Adwaita:dark')
hl.env('QT_QPA_PLATFORMTHEME', 'qt6ct')

hl.config({
  misc = {
    -- Wake the display on a keypress, so a manual `dpms off` is recoverable
    key_press_enables_dpms = true,

    force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
  },
})
