Headings = {
    north = 0,
    east = 1,
    south = 2,
    west = 3,
}

settings.define("heading", {
    description = "Heading of the turtle",
    default = Headings.north,
    type = number,
})

settings.define("wsid", {
    description = "Websocket channel",
    default = "0",
})

shell.run("delete json")
shell.run("wget https://pastebin.com/raw/4nRg9CHU json")

shell.run("delete startup.lua")
shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/startup.lua?t=" .. os.time())

shell.run("delete util.lua")
shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/util.lua?t=" .. os.time())

shell.run("delete movement.lua")
shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/movement.lua?t=" .. os.time())

shell.run("delete communication.lua")
shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/communication.lua?t=" .. os.time())

if (settings.get("goo.type") == "manager") then
    shell.run("delete manager.lua")
    shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/ManagerTurtle/manager.lua?t=" .. os.time())

    shell.run("manager")
elseif settings.get("goo.type" == "miner") then
    settings.define("minerID", {
        description = "Websocket channel",
        default = "0",
        type = string,
    })

    shell.run("delete manager.lua")
    shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/MinerTurtle/miner.lua?t=" .. os.time())

    shell.run("miner")
end