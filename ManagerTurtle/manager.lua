local movement = require "movement"
local ws = require "communication"

local function subdivideChunk(numBots)
    local subdivisions = {}
    
    return subdivisions
end

local function main()
    movement.moveUp(2)
    movement.moveDown(2)

    ws.sendSignal("ack", {
        message = "manager initialized"
    })
    while true do
        os.startTimer(1)
        os.pullEvent("timer")

        local subdivisions = subdivideChunk()
    end
end

parallel.waitForAny(main, ws.websocketHandler)