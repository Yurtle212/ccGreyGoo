local ws = require "communication"

local function interrupt()

end

local function excavate(subdivision)

end

local function main()
    while true do
        local timer_id = os.startTimer(1)
        local event, id
        repeat
            event, id = os.pullEvent("timer")
        until id == timer_id

        
    end
end

parallel.waitForAny(
    main,
    function()
        ws.websocketHandler(interrupt)
    end
)
