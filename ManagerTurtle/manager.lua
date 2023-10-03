local movement = require "movement"
local ws = require "communication"
local util = require "util"

MaxCraftingDepth = 5
InterruptCallbacks = {}

local function interrupt(signal)
    if (InterruptCallbacks[signal.type] ~= nil) then
        for index, callback in ipairs(InterruptCallbacks[signal.type]) do
            if (callback ~= nil) then
                InterruptCallbacks[signal.type][index] = nil
                callback(signal)
            end
        end
    end
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

local function transformedSubdivisions(subdivisions, position)
    local chunk = util.getChunk(position.x, position.z)
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
    if (amount == nil) then
        amount = 1
    end

    local chest = peripheral.wrap("top")
    local count = 0

    for slot = 1, chest.size(), 1 do
        local item = chest.getItemDetail(slot)
        if (item ~= nil) then
            local correctItem = false

            if (item.name == tag) then
                correctItem = true
            end

            for invTag, exists in pairs(item.tags) do
                if (correctItem) then
                    break
                end
                if (invTag == tag) then
                    if (item.count >= amount) then
                        correctItem = true
                        break
                    end
                    count = count + item.count
                end
            end

            if (correctItem) then
                return slot, item.count
            end
        end
    end
    return -1, count
end

local function pullItemFromInventory(slot, inv, amount)
    local origSlot = turtle.getSelectedSlot()

    if (slot ~= 1) then
        local result = inv.pushItems(peripheral.getName(inv), 1, 1, inv.size())
        if (result == 0 and inv.getItemDetail(1) ~= nil) then
            util.selectEmptySlot()
            turtle.suckUp()
            inv.pushItems(peripheral.getName(inv), slot, 1, 1)
            turtle.dropUp()
        else
            inv.pushItems(peripheral.getName(inv), slot, 1, 1)
        end
    end

    turtle.select(origSlot)
    turtle.suckUp(amount)
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

    local chest = peripheral.wrap("top")

    local maxLoops = 5
    local loop = 1


    for recipeItemIndex, recipeItemData in ipairs(recipe.recipe) do
        local ingredientAmount = (#recipeItemData.slots) * math.ceil(amount / recipe.amount)
        local tmp, count = getItemInInventory(recipeItemData.tag, ingredientAmount)
        if (tmp < 0) then
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

    util.emptyInventory()

    for recipeItemIndex, recipeItemData in ipairs(recipe.recipe) do
        local ingredientAmount = math.ceil(amount / recipe.amount)

        local tmp, count = getItemInInventory(recipeItemData.tag, ingredientAmount * #recipeItemData.slots)
        if (tmp == -1) then
            return false
        end

        for index, value in ipairs(recipeItemData.slots) do
            turtle.select(value)
            pullItemFromInventory(tmp, chest, ingredientAmount)
        end
    end

    return turtle.craft()
end

local function deployMiner(subdivisions, index, fuelAmount, position, heading)
    local deployCallback = function(signal)
        local chest = peripheral.wrap("top")

        local slot, amount = getItemInInventory("minecraft:coals", fuelAmount)
        util.selectEmptySlot()
        pullItemFromInventory(slot, chest, fuelAmount)
        turtle.drop()

        slot, amount = getItemInInventory("minecraft:diamond_pickaxe", 1)
        util.selectEmptySlot()
        pullItemFromInventory(slot, chest, 1)
        turtle.drop()

        ws.sendSignal("instructions", {
            position = position,
            heading = heading,
            subdivision = subdivisions[index],
            index = index,
            id = signal.data.id
        })
    end

    if (InterruptCallbacks["Awaiting Instructions"] == nil) then
        InterruptCallbacks["Awaiting Instructions"] = {}
    end

    InterruptCallbacks["Awaiting Instructions"][#InterruptCallbacks["Awaiting Instructions"] + 1] = deployCallback

    turtle.place()
    local timer_id = os.startTimer(1)
    local event, id
    repeat
        event, id = os.pullEvent("timer")
    until id == timer_id

    peripheral.wrap("front").turnOn()
end

local function mineChunk(position)
    local heading = movement.GetHeading(false)
    settings.set("heading", heading)
    settings.save()

    local slot, amount = getItemInInventory("computercraft:turtle")
    amount = math.min(amount, settings.get("goo.maxMiners"))

    local actualAmount = math.floor(math.sqrt(amount))
    actualAmount = actualAmount * actualAmount

    local subdivisions = subdivideChunk(actualAmount)
    subdivisions = transformedSubdivisions(subdivisions, position)

    local coalSlot, coalAmount = getItemInInventory("minecraft:coals")
    coalAmount = math.min(coalAmount / actualAmount, 16)

    local chest = peripheral.wrap("top")

    local deployPosition = movement.getForwardDelta(heading)

    for i = 1, actualAmount, 1 do
        if (not util.selectEmptySlot()) then
            turtle.select(1)
            turtle.dropUp()
        end
        pullItemFromInventory(slot, chest, 1)
        deployMiner(subdivisions, i, coalAmount, position, heading)
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

    -- local success = superCraft(recipes["minecraft:diamond_pickaxe"], recipes);
    -- ws.sendSignal("Crafted", success)
    position = vector.new(gps.locate())
    settings.set("position", position)

    mineChunk(position)

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
