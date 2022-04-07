-- This program removes 3 levels from a chunk.
-- The turtle must be placed on the floor, just outside the corner of the chunk. It'll dig out the area on the right.
-- Its original purpose was to find slime chunks more easily.

if not turtle then printError("Must be a turtle to run!") return end

local fuelMultiplier = 2
if term.isColor() then
    fuelMultiplier = 1
end
local fuelNeeded = fuelMultiplier * 288
local nextTurnRight = true

if turtle.getFuelLevel() < fuelNeeded then
    print("Not enough fuel!")
    return
end

print("Emptying inventory...")
for i=1, 16 do
    turtle.select(i)
    turtle.dropUp()
end
turtle.select(1)

local function forward()
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end
    if turtle.detectUp() then
        turtle.digUp()
    end
    if turtle.detectDown() then
        turtle.digDown()
    end
end

local function turn()
    if nextTurnRight then
        turtle.turnRight()
        forward()
        turtle.turnRight()
        nextTurnRight = false
    else
        turtle.turnLeft()
        forward()
        turtle.turnLeft()
        nextTurnRight = true
    end
end

turtle.up()
forward()
for _  = 1, 15 do
    for _ = 1, 15 do
        forward()
    end
    turn()
end
for _ = 1, 15 do
    forward()
end
turtle.turnRight()
for _ = 1, 15 do
    turtle.forward()
end
turtle.turnLeft()
turtle.forward()
turtle.down()
print("Emptying inventory...")
for i=1, 16 do
    turtle.select(i)
    turtle.drop()
end
turtle.turnLeft()
turtle.turnLeft()
