-- This program completely disables spawners by building a 9x9 platform around them and by putting torches on it.
-- The setup was originally made for blazes, so it ensures the light level is always higher than 11.
-- To use the program, place the turtle facing the spawner and on its same Y level, within 32 blocks from it.

-- Note#1: This program doesn't check fuel level, so make sure the turtle has at least ~200.

if not turtle then
    printError("Requires a Turtle")
    return
end

if not (turtle.getItemCount(1) == 64 and turtle.getItemCount(2) == 18 and turtle.getItemCount(3) == 13) then
    printError("You must place in slots:\n\t1: 64 full blocks\n\t2: 18 full blocks\n\t3: 13 torches")
    return
end

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

local function digUp()
    local bIsBlockPresent, tData = turtle.inspectUp()
    if bIsBlockPresent then
        if tData.name ~= "minecraft:spawner" then
            if not turtle.digUp() then
                turtle.attackUp()
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

local function up()
    while not turtle.up() do
        digUp()
    end
end

local left = turtle.turnLeft
local right = turtle.turnRight

local function changeTorchRow()
    left()
    forward(2)
    right()
    forward(2)
end

local function place(bTorch)
    if bTorch then
        turtle.select(3)
    elseif turtle.getItemCount(1) > 0 then
        turtle.select(1)
    else
        turtle.select(2)
    end
    turtle.placeDown()
end

local function fdPlace(nTimes, bTorch)
    print("fdPlace", nTimes, bTorch)
    if not nTimes or nTimes < 1 then
        nTimes = 1
    end

    for i = 1, nTimes do
        forward(1)
        place(bTorch)
    end
end

if not forward(32) then
    up()
    left()
    place()
    fdPlace(1, false)
    right()

    local nIter = 2
    while nIter <= 8.5 do
        fdPlace(math.floor(nIter), false)
        right()
        nIter = nIter + 0.5
    end

    fdPlace(8, false)
    right()
    forward(4)
    right()
    forward(4)

    up()
    place(true)
    right()
    changeTorchRow()
    for i = 1, 4 do
        place(true)
        right()
        forward(4)
    end
    changeTorchRow()
    for i = 1, 4 do
        place(true)
        right()
        forward(4)
        place(true)
        forward(4)
    end
else
    printError("Couldn't find the spawner.\nPlease place the turtle at its same Y level, facing it.")
    return
end