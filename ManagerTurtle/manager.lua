local movement = require "movement"
local ws = require "communication"
local util = require "util"

local function interrupt(signal)
    
end

local function subdivideChunk(numBots)
    local subdivisions = {}

    local width = math.floor(math.sqrt(numBots))

    for x = 1, width, 1 do
        for z = 1, width, 1 do
            subdivisions[((x - 1) * width) + z] = {
                x1 = math.floor(((x - 1) / width) * 16),
                x2 = math.floor((x / width) * 16) - 1,

                z1 = math.floor(((z - 1) / width) * 16),
                z2 = math.floor((z / width) * 16) - 1
            }
        end
    end

    return subdivisions
end

local function transformedSubdivisions(subdivisions)
    local x, y, z = gps.locate()
    local chunk = util.getChunk(x, z)
    local chunkCoords = {
        x = chunk.x * 16,
        z = chunk.z * 16
    }

    for index, value in ipairs(subdivisions) do
        subdivisions[index] = {
            x1 = value.x1 + chunkCoords.x,
            x2 = value.x2 + chunkCoords.x,
            z1 = value.z1 + chunkCoords.z,
            z2 = value.z2 + chunkCoords.z,
        }
    end

    return subdivisions
end

local function craft(recipe)
    recipe = textutils.unserialiseJSON(textutils.serialiseJSON(recipe))

    local chest = peripheral.wrap("bottom")
    for slot = 1, chest.size(), 1 do
        local item = chest.getItemDetail(slot)
        if (item ~= nil) then
            ws.sendSignal("print", item)

            for recipeItemIndex, recipeItemData in ipairs(recipe) do
                for invTag, exists in pairs(item.tags) do
                    ws.sendSignal("print", invTag)
                    if (invTag == recipeItemData.tag and item.count > #recipeItemData.slots) then
                        if (slot ~= 1) then
                            local result = chest.pushItems(peripheral.getName(chest), 1, 1, chest.size())
                            if (result == 0 and chest.getItemDetail(1) ~= nil) then
                                util.selectEmptySlot()
                                turtle.suckDown()
                                chest.pushItems(peripheral.getName(chest), slot, 1, 1)
                                turtle.dropDown()
                            else
                                chest.pushItems(peripheral.getName(chest), slot, 1, 1)
                            end
                        end
                        for index, value in ipairs(recipeItemData.slots) do
                            turtle.select(value)
                            turtle.suckDown(1)
                        end
                    end
                end
            end
        end
    end
end

local function main()
    ws.sendSignal("Initializing Grey Goo Manager")

    local x, y, z = gps.locate()
    local position = {
        x = x,
        y = y,
        z = z
    }

    ws.sendSignal("Grey Goo Manager Initialized", {
        position = position
    })

    local recipeFiles = fs.open("./craftingRecipes.json", "r")
    local recipes = textutils.unserialiseJSON(recipeFiles.readAll())
    recipeFiles.close()
    ws.sendSignal("recipes", recipes)

    local subdivisions = subdivideChunk(4)
    subdivisions = transformedSubdivisions(subdivisions)

    craft(recipes["computercraft:computer"].recipe)

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
    function ()
        ws.websocketHandler(interrupt)
    end
)