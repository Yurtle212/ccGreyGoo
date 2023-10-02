local util = require "util"

local function preMoveCheck(direction)
    if turtle.getFuelLevel() <= 0 then
        util.refuel()
    end

    return true;
end

local function move(direction, blocks)
    local success = true

    if (blocks == nil) then
        blocks = 1
    end

    while blocks > 0 do
        blocks = blocks - 1

        if preMoveCheck(direction) then
            if (direction == "forward") then
                if turtle.detect() then
                    turtle.dig()
                end
                turtle.forward()
            elseif (direction == "up") then
                if turtle.detectUp() then
                    turtle.digUp()
                end
                turtle.up()
            elseif (direction == "down") then
                if turtle.detectDown() then
                    turtle.digDown()
                end
                turtle.down()
            end
        else
            success = false
        end
    end
    return success
end

local function moveForward(blocks)
    return move("forward", blocks)
end

local function moveUp(blocks)
    return move("up", blocks)
end

local function moveDown(blocks)
    return move("down", blocks)
end

return { moveForward = moveForward, moveUp = moveUp, moveDown = moveDown }