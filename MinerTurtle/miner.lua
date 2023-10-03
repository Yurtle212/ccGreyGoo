local ws = require "communication"

InterruptCallbacks = {}

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
    ws.sendSignal("print", {
        message = "Excavating with data",
        data = data
    })
end

local function main()
    local function handleData(data)
        ReceivedData = data
    end

    if (InterruptCallbacks["instructions"] == nil) then
        InterruptCallbacks["instructions"] = {}
    end

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
    local channel = tostring(peripheral.wrap("back").getID())
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
