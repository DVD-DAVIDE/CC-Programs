-- This program was made to dig towards lower Y levels in the nether.
-- To use less fuel, several compromises were made, and it has several flaws.
-- In fact, I had to use another turtle to take the one running this program out of the lava.

if not turtle then
    printError("Requires a Turtle")
    return
end
local tArgs = {...}

local buildingItem = "minecraft:netherrack"

if #tArgs == 0 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <depth>")
    return
end

local depth = tonumber(tArgs[1])

local movementMultiplier = 2
if term.isColor() then movementMultiplier = 1 end
if depth * movementMultiplier * 2 > turtle.getFuelLevel() then
    printError("Not enough fuel!")
    return
end

local function selectUsefulSlot()
    local slot = nil
    local partialSlot = nil
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail(i)
        if item.name == buildingItem then
            if item.count >= 3 then
                if partialSlot then
                    turtle.transferTo(partialSlot)
                    slot = partialSlot
                    break
                else
                    slot = i
                    break
                end
            else
                partialSlot = i
            end
        end
    end
    if slot then
        turtle.select(slot)
        return true 
    end
    return false
end

local function down()
    while not turtle.down() do
        if not turtle.digDown() then
            turtle.attackDown()
        end
    end
end

local function digBack()
    turtle.turnRight()
    turtle.turnRight()
    if turtle.detect() then
        turtle.dig()
    end
    turtle.turnRight()
    --turtle.turnRight()
end

local function checkSides()
    --turtle.turnLeft()
    if not turtle.detect() then
        turtle.place()
    end
    turtle.turnRight()
    turtle.turnRight()
    if not turtle.detect() then
        turtle.place()
    end
    turtle.turnLeft()
end

local function forward()
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end
    if not turtle.detect() then
        turtle.place()
    end
end
local function dig()
    if selectUsefulSlot() then
    down()
    digBack()
    checkSides()
    forward()
    return true
    end
    return false
end

for i = 1, depth do
    dig()
    if i % 10 == 0 then
        print("Dug "..tostring(i).." blocks down.")
    end
end
print("Done.")