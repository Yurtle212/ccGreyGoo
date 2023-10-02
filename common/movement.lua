local util = require "util"

local function preMoveCheck()
    if turtle.getFuelLevel() <= 0 then
        util.refuel()
    end

    return true;
end

local function moveForward(blocks)
    local success = true

    if (blocks == nil) then
        blocks = 1
    end

    while blocks > 0 do
        blocks = blocks - 1

        if preMoveCheck() then
            turtle.moveForward()
        else
            success = false
        end
    end
    return success
end

local function moveUp(blocks)
    local success = true

    if (blocks == nil) then
        blocks = 1
    end

    while blocks > 0 do
        blocks = blocks - 1

        if preMoveCheck() then
            turtle.moveUp()
        else
            success = false
        end
    end
    return success
end

local function moveDown(blocks)
    local success = true

    if (blocks == nil) then
        blocks = 1
    end

    while blocks > 0 do
        blocks = blocks - 1

        if preMoveCheck() then
            turtle.moveDown()
        else
            success = false
        end
    end
    return success
end

return { moveForward = moveForward, moveUp = moveUp, moveDown = moveDown }