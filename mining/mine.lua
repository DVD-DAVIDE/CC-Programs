-- This program digs a straight tunnel.
-- It is optimized to use as little fuel as possible, while digging out the most blocks possible (so that it's easier to find ores).


if not turtle then printError("Must be a turtle to run!") return end

local tArgs = {...}

if #tArgs == 0 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
end

local length = tonumber(tArgs[1])

local movementMultiplier = 2
if term.isColor() then movementMultiplier = 1 end

if (length + 2) * movementMultiplier > turtle.getFuelLevel() then
    printError("Not enough fuel!")
    return
end

print("Emptying inventory...")
for i=1, 16 do
    turtle.select(i)
    turtle.dropUp()
end

turtle.select(1)
turtle.up()

for i=1, length do
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

    turtle.turnRight()
    if turtle.detect() then
        turtle.dig()
    end

    turtle.turnRight()
    turtle.turnRight()
    if turtle.detect() then
        turtle.dig()
    end
    turtle.turnRight()


    if i%10 == 0 then
        print(("Mined %d blocks..."):format(i))
    end
end
turtle.down()
print("Done.")