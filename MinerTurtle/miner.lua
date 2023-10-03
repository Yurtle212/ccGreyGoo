local ws = require "communication"

local function interrupt(signal)
    
end

local function excavate(subdivision)

end

local function main()
    ws.sendSignal("Awaiting Instructions", {
        id = os.getComputerID()
    })
end

local function init()
    local channel = tostring(peripheral.wrap("back").getID())
    settings.set("wsid", tostring(os.getComputerID()))

    parallel.waitForAny
    (
        main,
        function()
            ws.websocketHandler(interrupt)
        end
    )
end

init()
