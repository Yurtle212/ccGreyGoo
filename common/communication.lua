Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))

local function websocketHandler()
    while true do
        local raw = Websocket.receive()
        if (raw == nil) then
            print("re-init websocket")
            os.startTimer(2)
            os.pullEvent("timer")

            Websocket = assert(http.websocket("wss://yurtle.net/cc/" .. settings.get("wsid")))
        elseif raw ~= nil then
            local signal = json.decode(raw)
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
    Websocket.send(json.encode({
        type = "signal",
        data = {

        }
    }))
end

return { websocketHandler = websocketHandler }
