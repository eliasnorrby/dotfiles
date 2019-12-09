local log = hs.logger.new('wifi.lua', 'debug')
local SSID = "SJ"

local wifi = {}

wifi.connect = function()
  log.d('Attempting to connect to ' .. SSID)
  local currentNetwork = hs.wifi.currentNetwork()
  -- local networkList = hs.wifi.availableNetworks()
  -- log.d(hs.inspect(networkList))
  if (currentNetwork ~= nil) then
    log.d('Already connected to a network, exiting')
    hs.notify.new({title='Network', informativeText='Already connected to network ' .. currentNetwork}):send()
    return
  else
    log.d('Not connected, trying to connect...')
    hs.notify.new({title='Network', informativeText='Connecting to ' .. SSID .. '...'}):send()
    success = hs.wifi.associate(SSID, "")
    if (success) then
      log.d('Successfully connected')
      hs.notify.new({title='Network', informativeText='Successfully connected to ' .. SSID}):send()
    else
      log.d('Could not connect to ' .. SSID)
      hs.notify.new({title='Network', informativeText='Failed to connect to ' .. SSID}):send()
    end
  end
end

return wifi
