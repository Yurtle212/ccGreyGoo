local movement = require "movement"
local ws = require "communication"

local function subdivideChunk(numBots)
    local subdivisions = {}

    local width = math.floor(math.sqrt(numBots))

    for x = 1, width, 1 do
        for z = 1, width, 1 do
            subdivisions[((x-1) * width) + z] = {
                x1 = math.floor(((x-1) / width) * 16),
                x2 = math.floor((x / width) * 16)-1,

                z1 = math.floor(((z-1) / width) * 16),
                z2 = math.floor((z / width) * 16)-1
            }
        end
    end

    return subdivisions
end

local function main()
    movement.moveUp(2)
    movement.moveDown(2)

    ws.sendSignal("ack", {
        message = "manager initialized"
    })

    local subdivisions = subdivideChunk()
    print()
    while true do
        os.startTimer(1)
        os.pullEvent("timer")

        
    end
end

parallel.waitForAny(main, ws.websocketHandler)