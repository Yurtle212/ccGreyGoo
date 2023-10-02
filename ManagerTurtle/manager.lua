local movement = require "movement"
local ws = require "communication"

local function main()
    while true do
        sleep(1)
    end
end

parallel.waitForAny(main, ws.websocketHandler)