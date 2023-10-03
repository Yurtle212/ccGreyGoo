local movement = require "movement"
local ws = require "communication"
local util = require "util"

MaxCraftingDepth = 5

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

local function getItemInInventory(tag, amount)
    local chest = peripheral.wrap("bottom")
    local count = 0

    for slot = 1, chest.size(), 1 do
        local item = chest.getItemDetail(slot)
        if (item ~= nil) then
            for invTag, exists in pairs(item.tags) do
                if (invTag == tag) then
                    if (item.count >= amount) then
                        return slot, item.count
                    end
                    count = count + item.count
                end
            end
        end
    end
    return -1, count
end

local function superCraft(recipe, recipes, amount, depth)
    if (amount == nil) then
        amount = 1
    end

    ws.sendSignal("Crafting", {
        recipe = recipe,
        amount = amount
    })

    if (depth == nil) then
        depth = 0
    elseif depth > MaxCraftingDepth then
        return false
    end

    local chest = peripheral.wrap("bottom")

    local maxLoops = 5
    local loop = 1

    local ready = false

    for recipeItemIndex, recipeItemData in ipairs(recipe.recipe) do
        local ingredientAmount = (#recipeItemData.slots) * math.ceil(amount / recipe.amount)
        local tmp, count = getItemInInventory(recipeItemData.tag, ingredientAmount)
        if (tmp < 0) then
            ready = false
            for recipeTag, recipeData in pairs(recipes) do
                if (recipeTag == recipeItemData.tag) then
                    if (superCraft(recipeData, recipes, ingredientAmount - count, depth + 1)) then
                        break
                    else
                        return false
                    end
                end
            end
        end
    end

    if not ready then
        return false
    end

    util.emptyInventory()

    for recipeItemIndex, recipeItemData in ipairs(recipe.recipe) do
        local tmp, count = getItemInInventory(recipeItemData.tag, #recipeItemData.slots)
        if (tmp ~= 1) then
            local result = chest.pushItems(peripheral.getName(chest), 1, 1, chest.size())
            if (result == 0 and chest.getItemDetail(1) ~= nil) then
                util.selectEmptySlot()
                turtle.suckDown()
                chest.pushItems(peripheral.getName(chest), tmp, 1, 1)
                turtle.dropDown()
            else
                chest.pushItems(peripheral.getName(chest), tmp, 1, 1)
            end
        end

        local ingredientAmount = (#recipeItemData.slots) * math.floor(amount / recipe.amount)
        for index, value in ipairs(recipeItemData.slots) do
            turtle.select(value)
            turtle.suckDown(ingredientAmount)
        end
    end

    return turtle.craft()
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

    superCraft(recipes["computercraft:turtle"], recipes);
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
