local util = require "util"

Headings = {
    negative_x = 1,
    negative_z = 2,
    positive_x = 3,
    positive_z = 0,
}

local function preMoveCheck(direction)
    if turtle.getFuelLevel() <= 0 then
        return util.refuel()
    end

    return true;
end

local function getForwardDelta(heading)
    if (heading == nil) then
        heading = GetHeading(true)
    end
    local delta = vector.new(0,0,0)

    if heading == Headings.negative_x then
        delta = vector.new(-1, 0, 0)
    elseif heading == Headings.positive_x then
        delta = vector.new(1, 0, 0)
    elseif heading == Headings.negative_z then
        delta = vector.new(0, 0, -1)
    elseif heading == Headings.positive_z then
        delta = vector.new(0, 0, 1)
    end
    
    return delta
end

local function move(direction, blocks)
    local success = true
    local position = settings.get("position")

    if (blocks == nil) then
        blocks = 1
    end

    local retries = 5

    while blocks > 0 do
        blocks = blocks - 1

        if preMoveCheck(direction) and retries >= 0 then
            if (direction == "forward") then
                if turtle.detect() then
                    turtle.dig()
                end
                
                local delta = getForwardDelta(GetHeading(true))
                if not turtle.forward() then
                    blocks = blocks + 1
                    retries = retries - 1
                else
                    retries = 5
                    position = position + delta
                end
            elseif (direction == "backward") then
                local delta = getForwardDelta((GetHeading(true) + 2) % 4)
                if not turtle.back() then
                    blocks = blocks + 1
                    retries = retries - 1
                else
                    retries = 5
                    position = position + delta
                end
            elseif (direction == "up") then
                if turtle.detectUp() then
                    turtle.digUp()
                end
                local delta = vector.new(0,1,0)
                if not turtle.up() then
                    blocks = blocks + 1
                    retries = retries - 1
                else
                    retries = 5
                    position = position + delta
                end
            elseif (direction == "down") then
                if turtle.detectDown() then
                    turtle.digDown()
                end

                local delta = vector.new(0,-1,0)
                if not turtle.down() then
                    blocks = blocks + 1
                    retries = retries - 1
                else
                    retries = 5
                    position = position + delta
                end
            end
        else
            success = false
            break
        end
    end

    settings.set("position", position)
    settings.save()
    return success
end

local function moveForward(blocks)
    return move("forward", blocks)
end

local function moveBackward(blocks)
    return move("backward", blocks)
end

local function moveUp(blocks)
    return move("up", blocks)
end

local function moveDown(blocks)
    return move("down", blocks)
end

function GetHeading(simple)
    if (simple == nil) then
        simple = true
    end

    local x,y,z = gps.locate(2, false)

    if (simple or x == nil) then
        return settings.get("heading")
    else
        local start_pos = vector.new(x,y,z)
        moveForward(1)
        local end_pos = vector.new(gps.locate(2, false))
        local heading = end_pos - start_pos
        moveBackward(1)
        return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3)) % 4 -- https://www.computercraft.info/forums2/index.php?/topic/1704-get-the-direction-the-turtle-face/
    end
end

local function turn(direction, amount)
    if (amount == nil) then
        amount = 1
    end

    local heading = GetHeading(true)
    local success = true

    for i = 1, amount, 1 do
        if direction == "left" then
            if turtle.turnLeft() then
                heading = heading - 1
            else
                success = false
                break
            end
        elseif direction == "right" then
            if turtle.turnRight() then
                heading = heading - 1
            else
                success = false
                break
            end
        end
        
        heading = heading % 4
    end

    settings.set("heading", heading)
    return success
end

local function turnLeft(amount)
    return turn("left", amount)
end

local function turnRight(amount)
    return turn("right", amount)
end

local function turnToHeading(goalHeading)
    local heading = GetHeading(true)
    local retries = 5

    while heading ~= goalHeading and retries >= 0 do
        if goalHeading > heading then
            if math.abs(heading - goalHeading) > 2 then
                turnRight()
            else
                turnLeft()
            end
        else
            if math.abs(heading - goalHeading) > 2 then
                turnLeft()
            else
                turnRight()
            end
        end
        retries = retries - 1
    end
end

local function moveTo(goalPos)
    local retries = 5

    while settings.get("position").y ~= goalPos.y and retries >= 0 do
        if (settings.get("position").y < goalPos.y) then
            if not moveUp(goalPos.y - settings.get("position").y) then
                retries = retries - 1
            else
                retries = 5
            end
        else
            if not moveDown(settings.get("position").y - goalPos.y) then
                retries = retries - 1
            else
                retries = 5
            end
        end
    end

    while settings.get("position").x ~= goalPos.x and retries >= 0 do
        if (settings.get("position").x < goalPos.x) then
            turnToHeading(Headings.positive_x)
            if not moveForward(goalPos.x - settings.get("position").x) then
                retries = retries - 1
            else
                retries = 5
            end
        else
            turnToHeading(Headings.negative_x)
            if not moveForward(settings.get("position").x - goalPos.x) then
                retries = retries - 1
            else
                retries = 5
            end
        end
    end

    while settings.get("position").z ~= goalPos.z and retries >= 0 do
        if (settings.get("position").z < goalPos.z) then
            turnToHeading(Headings.positive_z)
            if not moveForward(goalPos.z - settings.get("position").z) then
                retries = retries - 1
            else
                retries = 5
            end
        else
            turnToHeading(Headings.negative_z)
            if not moveForward(settings.get("position").z - goalPos.z) then
                retries = retries - 1
            else
                retries = 5
            end
        end
    end
end

return { moveForward = moveForward, moveUp = moveUp, moveDown = moveDown, GetHeading = GetHeading, turnLeft = turnLeft, turnRight = turnRight, moveTo = moveTo, getForwardDelta = getForwardDelta, Headings = Headings }