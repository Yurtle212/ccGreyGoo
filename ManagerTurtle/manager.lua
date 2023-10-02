local movement = require "movement"
local ws = require "communication"

local function main()
    
end

parallel.waitForAny(main, ws.websocketHandler)