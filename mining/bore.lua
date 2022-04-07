-- This program digs a 1x2 borehole and builds a floor if there's void or a fluid down.

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

if length * movementMultiplier > turtle.getFuelLevel() then
    printError("Not enough fuel!")
    return
end

print("Emptying inventory...")
for i=1, 16 do
    turtle.select(i)
    turtle.dropUp()
end
turtle.select(1)

print("Put 32 cobblestone blocks in slot #1.")



while true do
    local slot1 = turtle.getItemDetail(1)
    if slot1 and slot1.name == "minecraft:cobblestone" and slot1.count >= 32 then
        break
    end
    sleep(2)
end

for i=1, length do
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end

    if turtle.detectUp() then
        turtle.digUp()
    end

    if not turtle.detectDown() then
        turtle.placeDown()
    end

    if i%10 == 0 then
        print(("Mined %d blocks"):format(i))
    end
end