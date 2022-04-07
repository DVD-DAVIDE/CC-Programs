-- This program removes the platform built by 'spawner-secure.lua'.
-- The turtle must be placed 1 block from the platform, centered and on its same Y level.
-- It was made this way in case one disabled the spawner and made a cage around it (e.g. to use it for a farm).
-- For this reason, once it has returned to the start, it places a block in front of itself.

-- Note#1: the program doesn't check fuel level. Make sure it has at least ~100.
-- Note#2: the program doesn't select a slot on its own, so it'll try to place from the already selected slot. Select another slot if you'd like.

if not turtle then
    printError("Requires a Turtle")
    return
end

local bNextRight = true

local function dig()
    local bIsBlockPresent, tData = turtle.inspect()
    if bIsBlockPresent then
        if tData.name ~= "minecraft:spawner" then
            if not turtle.dig() then
                turtle.attack()
                return 1
            end
            return 1
        end
        return -1
    end
    return 0
end

local function forward(nBlocks)
    if not nBlocks or nBlocks < 1 then
        nBlocks = 1
    end

    for i = 1, nBlocks do
        while not turtle.forward() do
            if dig() == -1 then
                return false
            end
        end
    end

    return true
end

local left = turtle.turnLeft
local right = turtle.turnRight

local function nextRowLeft()
    left()
    forward(1)
    left()
end

local function nextRowRight()
    right()
    forward(1)
    right()
end

local function nextRow()
    if bNextRight then
        nextRowRight()
        bNextRight = false
    else
        nextRowLeft()
        bNextRight = true
    end
end

--Get in position
forward(2)
left()
forward(4)
right()
--Start
for i = 1, 8 do
    if not forward(8) then
        left()
        forward(1)
        right()
        forward(2)
        right()
        forward(1)
        left()
        forward(3)
    end
    nextRow()
end
--Complete last row
forward(8)
--Go back
right()
right()
forward(8)
right()
forward(4)
left()
forward(2)
right()
right()
turtle.place()