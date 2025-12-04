-- Keybindings for launching apps in App Mode
-- h, j, k, l occupied by arrow key mappings
return {
  { 'a', 'Google Meet' },
  { 'b', 'Adobe Lightroom' },
  { 'c', 'Google Chrome' },
  { 'd', 'Drafts' },
  {
    'd',
    function()
      hs.execute('open ~/Downloads')
    end,
    { 'shift' },
  },
  -- { 'e', 'Mimestream' },
  { 'f', 'Fantastical' },
  {
    'f',
    function()
      hs.execute('open ~')
    end,
    { 'shift' },
  },
  { 'g', 'Things3' },
  { 'i', 'Insomnia' },
  { 'm', 'Microsoft Teams' },
  -- { 'n', '?'},
  { 'o', 'Obsidian' },
  {
    'p',
    function()
      hs.eventtap.keyStroke({ 'cmd', 'alt' }, '\\', 0)
    end,
  },
  { 'q', 'ChatGPT' },
  { 'r', 'Alacritty' },
  { 's', 'Emacs' },
  { 't', 'kitty' },
  { 't', 'ghostty', { 'shift' } },
  { 'u', 'Spotify' },
  { 'v', 'Notion' },
  { 'w', 'Linear' },
  { 'x', 'Firefox Developer Edition' },
  { 'y', 'DaVinci Resolve' },
  { 'z', 'Slack' },
}
