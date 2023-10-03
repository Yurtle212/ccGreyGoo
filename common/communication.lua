-- os.loadAPI("json")

Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))
WebsocketOpen = false

local function websocketHandler()
    while true do
        local raw = Websocket.receive()
        if (raw == nil) then
            print("re-init websocket")
            WebsocketOpen = false
            os.startTimer(2)
            os.pullEvent("timer")

            Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))
            WebsocketOpen = true
        elseif raw ~= nil then
            local signal = textutils.unserialiseJSON(raw)
            if signal.type == "reboot" then
                shell.run("delete startup.lua")
                shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/startup.lua?t=" ..
                    os.time())

                shell.run("reboot")
            end
        end
    end
end

local function sendSignal(signalType, data)
    while ~WebsocketOpen do
        sleep(1)
    end
    Websocket.send(textutils.serialiseJSON({
        type = signalType,
        data = data,
        timestamp = os.time()
    }))
end

return { websocketHandler = websocketHandler, sendSignal = sendSignal }
