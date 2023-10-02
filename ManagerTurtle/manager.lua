local movement = require "movement"
local ws = require "communication"
local util = require "util"

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

local function transformedSubdivisions(subdivisions)
    local x, y, z = gps.locate()
    local chunk = util.getChunk(x, z)
    local chunkCoords = {
        x = chunk.x * 16,
        z = chunk.z * 16
    }

    for index, value in ipairs(subdivisions) do
        subdivisions[index] = {
            x1 = value.x1 + chunkCoords.x,
            x2 = value.x2 + chunkCoords.x,
            z1 = value.z1 + chunkCoords.z,
            z2 = value.z2 + chunkCoords.z,
        }
    end

    return subdivisions
end

local function main()
    movement.moveUp(2)
    movement.moveDown(2)

    local x,y,z = gps.locate()
    local position = {
        x = x,
        y = y,
        z = z
    }

    ws.sendSignal("Grey Goo Manager Initialized", {
        message = "manager initialized",
        position = position
    })

    local subdivisions = subdivideChunk(4)
    ws.sendSignal("subdivisions", subdivisions)

    subdivisions = transformedSubdivisions(subdivisions)
    ws.sendSignal("subdivisions", subdivisions)

    while true do
        os.startTimer(1)
        os.pullEvent("timer")

        
    end
end

parallel.waitForAny(main, ws.websocketHandler)