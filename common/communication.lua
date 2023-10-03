-- os.loadAPI("json")

Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))
WebsocketOpen = true

local function websocketHandler(interrupt)
    while true do
        local raw = Websocket.receive()
        if (raw == nil) then
            print("re-init websocket")
            WebsocketOpen = false
            local timer_id = os.startTimer(2)
            local event, id
            repeat
                event, id = os.pullEvent("timer")
            until id == timer_id

            Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))
            WebsocketOpen = true
        elseif raw ~= nil then
            local signal = textutils.unserialiseJSON(raw)
            if signal.type == "reboot" then
                shell.run("delete startup.lua")
                shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/startup.lua?t=" ..
                    os.time())

                shell.run("reboot")
            else
                interrupt(signal)
            end
        end
    end
end

local function sendSignal(signalType, data)
    while not WebsocketOpen do
        local timer_id = os.startTimer(2)
        local event, id
        repeat
            event, id = os.pullEvent("timer")
        until id == timer_id
    end
    Websocket.send(textutils.serialiseJSON({
        type = signalType,
        data = data,
        timestamp = os.time()
    }))
end

return { websocketHandler = websocketHandler, sendSignal = sendSignal }
