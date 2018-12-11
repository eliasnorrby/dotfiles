-- A global variable for the Hyper Mode
code = hs.hotkey.modal.new()
local filter = hs.window.filter.new('Code')
enableModalForWindowsMatchingFilter(filter, code)

function enterCode()
  enablehotkeys
end

function exitCodeMode()
  disablehotkeys
end

local codeHotkeys = bindContextKeys(paneHotkeyMappings['Code'])
local filter = hs.window.filter.new('Code')

-- =================================
function bindContextKeys(map)
  local boundHotkeys
  hs.fnutils.each(map[mappings], function(mapping)
    local app = map['app']
    print('========== Binding keys for')
    print(app)
 
    print("--- binding new thing: ")
    print(mapping['name'])
    local fromMods = mapping['from'][1]
    print('fromMods: ')
    hs.fnutils.each(fromMods, function(m)
      print(m)
    end)
    local fromKey = mapping['from'][2]
    print('fromKey: ')
    print(fromKey)
    local toMods = mapping['to'][1]
    print('toMods: ')
    hs.fnutils.each(toMods, function(m)
      print(m)
    end)
    local toKey = mapping['to'][2]
    print('toKey: ')
    print(toKey)
    hyper:bind(fromMods, fromKey, function() 
      keyUpDown(toMods, toKey)
    end)
  end)
end


-- Panes
-- Split : -
local mySplitMods = {'ctrl', 'alt'}
local mySplitKey = 'ä'

-- Select left : u
local mySelectLeftMods = {'ctrl', 'alt'}
local mySelectLeftKey = 'u'


-- Select right : i
local mySelectRightMods = {'ctrl', 'alt'}
local mySelectRightKey = 'i'


-- Resize left : alt + u
local myResizeLeftMods = {'alt'}
local myResizeLeftKey = 'u'


-- Resize right : alt + i
local myResizeRightMods = {'alt'} 
local myResizeRightKey = 'i'

-- Move left : 
local myMoveLeftMods = {'alt', 'shift'}
local myMoveLeftKey = 'u'

-- Move right :
local myMoveRightMods = {'alt', 'shift'}
local myMoveRightKey = 'i'

hyper:bind({}, 'ä', function()
  print('pressed ä')
  keyUpDown(hyper.mods, 'u')
end)


local paneHotkeyMappings = {
  Code = {
    app = 'Code',
    mappings = {
      -- split = {
      {
        name = 'split',
        from = {mySplitMods, mySplitKey},
        to = {{'ctrl', 'shift', 'cmd'}, '-'},
      },
      -- selectLeft = {
      {
        name = 'selectLeft',
        from = {mySelectLeftMods, mySelectLeftKey},
        to = {{'ctrl', 'shift', 'cmd'}, 'u'}
      },
      -- selectRight = {
      {
        name = 'selectRight',
        from = {mySelectRightMods, mySelectRightKey},
        to = {{'ctrl', 'shift', 'cmd'}, 'i'}
      },
      -- resizeLeft = {
      -- name = '',
      -- from = {myResizeLeftMods, myResizeLeftKey}
      --   to = {}
      -- },
      -- resizeRight = {
      -- name = '',
      -- from = {myResizeRightMods, myResizeRightKey}
      --   to = {}
      -- },
      -- moveLeft = {
      {
        name = 'moveLeft',
        from = {myMoveLeftMods, myMoveLeftKey},
        to = {{'ctrl', 'shift', 'cmd', 'alt'}, 'u'}
      },
      -- moveRight = {
      {
        name = 'moveRight',
        from = {myMoveRightMods, myMoveRightKey},
        to = {{'ctrl', 'shift', 'cmd', 'alt'}, 'i'}
      },
    },
  },
  {
    app = 'iTerm2',
    mappings = {
      -- split = {
      {
        from = {mySplitMods, mySplitKey},
        to = {{'ctrl'}, '-'},
      },
      -- selectLeft = {
      {
        from = {mySelectLeftMods, mySelectLeftKey},
        to = {{'ctrl'}, 'u'}
      },
      -- selectRight = {
      {
        from = {mySelectRightMods, mySelectRightKey},
        to = {{'ctrl'}, 'i'}
      },
      -- resizeLeft = {
      {
        from = {myResizeLeftMods, myResizeLeftKey},
        to = {{'ctrl'}, 'h'}
      },
      -- resizeRight = {
      {
        from = {myResizeRightMods, myResizeRightKey},
        to = {{'ctrl'}, 'l'}
      },
    },
  },
}