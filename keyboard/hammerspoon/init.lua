local log = hs.logger.new('init.lua', 'debug')
local hotspotSSID = ""
local hotspotPASSPHRASE = ""

-- Use Control+å to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '[', nil, function()
  hs.reload()
end)

keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

message = require('keyboard.status-message')
statusMessage = message.new('Config reloaded!')
statusMessage:notify(1)


-- Load submodules
require('keyboard.hyper')
require('keyboard.app-mode')
-- require('keyboard.tab-mode')
require('keyboard.windows')

-- Vim Spoon
-- vim = hs.loadSpoon('VimMode')
-- vim:enableKeySequence('j', 'k')



-- Load hotspot info

function loadHotspotInfo ()
	dirpath = hs.fs.currentDir() .. '/keyboard/'
	ssidPath = dirpath .. 'hotspotSSID'
	passPath = dirpath .. 'hotspotPASSPHRASE'
	local ssid, success, uselessvar, anotheruselessvar = hs.execute("cat " .. ssidPath)
	if (not success) then
		hs.notify.new({title='Warning', informativeText='Could not find config for hotspot shortcut'}):send()
		return false
	end
	local pass, success, uselessvar, anotheruselessvar = hs.execute("cat " .. passPath)
	if (not success) then
		hs.notify.new({title='Warning', informativeText="Could not find config for hotspot shortcut"}):send()
		return false
	end
	hotspotSSID = ssid
	hotspotPASSPHRASE = pass
	return true
end

hs.hotkey.bind({'ctrl', 'cmd', 'alt'}, 'n', function()
	log.d('Attempting to connect to hotspot')
	if (loadHotspotInfo()) then
		log.d('Found hotspot config')
	else
		log.d('Found no hotspot config, exiting')
		return 1
	end

	local currentNetwork = hs.wifi.currentNetwork()
	-- local networkList = hs.wifi.availableNetworks()
	-- log.d(hs.inspect(networkList))
	if (currentNetwork ~= nil) then
		log.d('Already connected to a network, exiting')
		message.new('Already connected to network ' .. currentNetwork):notify(2)
		hs.notify.new({title='Network', informativeText='Already connected to network ' .. currentNetwork}):send()
		return
	else
		log.d('Not connected, trying to reach hotspot...')
		-- message.new('Connecting to hotspot...'):notify(5)
		hs.notify.new({title='Network', informativeText='Connecting to hotspot...'}):send()
		success = hs.wifi.associate(hotspotSSID, hotspotPASSPHRASE)
		if (success) then
			log.d('Successfully connected')
			-- message.new('Successfully connected to hotspot'):notify(2)
			hs.notify.new({title='Network', informativeText='Successfully connected to hotspot'}):send()
		else
			log.d('Could not reach hotspot')
			-- message.new('Failed to connect to hotspot'):notify(2)
			hs.notify.new({title='Network', informativeText='Failed to connect to hotspot'}):send()
		end
	end
end)

hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤓🤘'}):send()