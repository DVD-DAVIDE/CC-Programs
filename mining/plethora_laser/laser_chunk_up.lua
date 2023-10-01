local completion = require "cc.completion"

local function up()
    while not turtle.up() do
        if not turtle.digUp() and not turtle.attackUp() then
            return false
        end
    end
    return true
end

write("Laser side: ")
local laser = peripheral.wrap(read(
    nil,
    nil,
    function (text)
        return completion.choice(text, peripheral.getNames())
    end
))
local move
if gps.locate() then
    local _, y, _ = gps.locate()
    write("Dig until y = ")
    move = (tonumber(read()) or y) - y
else
    write("Dig up for: ")
    move = tonumber(read)
end

if 2 * move > turtle.getFuelLevel() then
    printError("Not enough fuel!")
    return
end

while move > 0 do
    if up() then
        move = move - 1
    else
        move = 0
    end
    for yaw = 1, 360, 0.75 do
        laser.fire(yaw, 0, 5)
    end
end

print("End program")