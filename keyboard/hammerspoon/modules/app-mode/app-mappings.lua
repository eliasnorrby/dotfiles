PausedSpotify = false

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
  {
    'e',
    function()
      if hs.spotify.isPlaying() then
        hs.spotify.pause()
        PausedSpotify = true
      elseif PausedSpotify then
        hs.timer.doAfter(2, function()
          hs.spotify.play()
          PausedSpotify = false
        end)
      end
      hs.eventtap.keyStroke({ 'cmd', 'alt', 'shift' }, 'w', 0)
    end,
  },
  {
    'e',
    function()
      hs.eventtap.keyStroke({ 'cmd', 'alt', 'shift' }, 'm', 0)
    end,
    { 'shift' },
  },
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
  { 'q', 'Claude' },
  { 'r', 'Alacritty' },
  { 's', 'Emacs' },
  { 't', 'kitty' },
  { 't', 'ghostty', { 'shift' } },
  { 'u', 'Spotify' },
  { 'v', 'Notion' },
  { 'w', 'Linear' },
  { 'x', 'Google Chrome' },
  { 'y', 'DaVinci Resolve' },
  { 'z', 'Slack' },
}
