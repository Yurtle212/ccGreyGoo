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

shell.run("delete json")
shell.run("wget https://pastebin.com/raw/4nRg9CHU json")

shell.run("delete startup.lua")
shell.run("wget https://raw.githubusercontent.com/Yurtle212/ccGreyGoo/main/common/startup.lua")