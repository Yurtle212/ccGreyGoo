local movement = require "movement"
local ws = require "communication"

local function main()
    while true do
        os.startTimer(1)
        os.pullEvent("timer")

        
    end
end

parallel.waitForAny(main, ws.websocketHandler)