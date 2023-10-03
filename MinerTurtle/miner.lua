local ws = require "communication"
local util = require "util"
local move = require "movement"

InterruptCallbacks = {}

-- Filters = {
--     "minecraft:coals",
--     "forge:gems/diamond",
--     "forge:dusts/redstone",
--     "minecraft:planks"
-- }

local function interrupt(signal)
    if (InterruptCallbacks[signal.type] ~= nil) then
        for index, callback in ipairs(InterruptCallbacks[signal.type]) do
            if (callback ~= nil) then
                callback(signal)
                InterruptCallbacks[signal.type][index] = nil
            end
        end
    end
end

ReceivedData = nil
local state = "idle"

local function excavate(data)
    turtle.select(util.findItemInInventory("minecraft:diamond_pickaxe"))
    turtle.equipRight()

    ws.sendSignal("print", {
        message = "Excavating with data",
        data = data
    })

    local startPos = vector.new(data.subdivision.x1, data.position.y - 1, data.subdivision.z1)
    move.moveTo(startPos)
end

local function main()
    local function handleData(data)
        local pos = vector.new(data.data.position.x, data.data.position.y, data.data.position.z)
        settings.set("position", pos)
        settings.set("heading", data.data.heading)
        settings.save()
        ReceivedData = data.data
    end

    if (InterruptCallbacks["instructions"] == nil) then
        InterruptCallbacks["instructions"] = {}
    end
    InterruptCallbacks["instructions"][#InterruptCallbacks["instructions"]+1] = handleData

    ws.sendSignal("Awaiting Instructions", {
        id = os.getComputerID()
    })

    while true do
        local timer_id = os.startTimer(2)
        local event, id
        repeat
            event, id = os.pullEvent("timer")
        until id == timer_id

        if (state == "idle" and ReceivedData ~= nil) then
            state = "excavating"
            excavate(ReceivedData)
        end
    end
end

local function init()
    local parent = peripheral.wrap("back")
    while parent == nil do
        move.turnLeft()
        parent = peripheral.wrap("back")
    end

    local channel = tostring(parent.getID())
    settings.set("wsid", channel)
    settings.save()

    parallel.waitForAny(
        main,
        function()
            ws.websocketHandler(interrupt)
        end
    )
end

init()
