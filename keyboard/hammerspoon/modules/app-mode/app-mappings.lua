-- Keybindings for launching apps in App Mode
-- h, j, k, l occupied by arrow key mappings
return {
  { 'a', 'Google Meet' },
  { 'b', 'Adobe Lightroom' },
  { 'c', 'Google Chrome' },      -- "C" for "Chrome"
  { 'd', 'Drafts' },             -- "D" for "Drafts"
  -- { 'e', '?' },
  { 'f', 'Fantastical' },        -- "F" for "Fantastical"
  { 'g', 'Things3' },            -- "G" for "GTD"
  { 'i', 'Insomnia' },            -- "I" for "Insomnia"
  -- { 'm', 'Microsoft Teams classic' },
  { 'm', function () hs.eventtap.keyStroke('ctrl', '2', 0) end },
  -- { 'n', '?'},
  { 'o', 'Obsidian' },
  -- { 'p', '?' },               -- occupied by 1Password shortcut
  { 'q', '' },
  { 'r', 'Alacritty' },
  { 's', 'Emacs' },
  { 't', 'kitty' },              -- "T" for "Terminal"
  { 'u', 'Spotify' },
  { 'v', 'Notion' },
  { 'w', 'Linear' },
  { 'x', 'Firefox Developer Edition' },
  -- { 'y', '?' },
  { 'z', 'Slack' },

  { 'd', function() hs.execute('open ~/Downloads') end, {'shift'} },
}
