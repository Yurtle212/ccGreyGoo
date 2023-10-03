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

settings.define("goo.type", {
    description = "goo type",
    default = "miner",
})

settings.set("ChannelBytes", 4)

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
    settings.define("goo.maxMiners", {
        description = "Max miners to assign to this manager",
        default = 64,
        type = number
    })

    settings.set("wsid", tostring(os.getComputerID()))

    shell.run("delete craftingRecipes.json")
    shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/ManagerTurtle/craftingRecipes.json?t=" .. os.time())

    shell.run("delete manager.lua")
    shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/ManagerTurtle/manager.lua?t=" .. os.time())

    shell.run("manager")
elseif (settings.get("goo.type") == "miner") then
    settings.define("minerID", {
        description = "Miner id",
        default = 0,
        type = number,
    })

    shell.run("delete manager.lua")
    shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/MinerTurtle/miner.lua?t=" .. os.time())

    shell.run("miner")
end