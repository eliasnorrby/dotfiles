-- Keybindings for launching apps in App Mode
-- h, j, k, l occupied by arrow key mappings
return {
  { 'a', 'Google Meet' },
  -- { 'b', '?' },
  { 'c', 'Google Chrome' },      -- "C" for "Chrome"
  { 'd', 'Drafts' },             -- "D" for "Drafts"
  { 'e', 'Adobe Lightroom' },    -- "E" for "Edit"
  { 'f', 'Fantastical' },        -- "F" for "Fantastical"
  { 'g', 'Things3' },             -- "G" for "GTD"
  { 'i', 'Insomnia'},            -- "I" for "Insomnia"
  { 'm', 'iMovie'},
  { 'n', 'Postman'},
  { 'o', 'OmniFocus' },
  -- { 'p', '?' },               -- occupied by 1Password shortcut
  { 'q', 'Obsidian' },
  { 'r', 'Alacritty' },
  { 's', 'Emacs' },
  { 't', 'kitty' },              -- "T" for "Terminal"
  { 'u', 'Spotify' },
  { 'v', 'Notion' },
  { 'w', 'zoom.us' },
  { 'x', 'Firefox Developer Edition' },
  { 'y', 'Linear' },
  { 'z', 'Slack' },

  { 'd', function() hs.execute('open ~/Downloads') end, {'shift'} },
}
