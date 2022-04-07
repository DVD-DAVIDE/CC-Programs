--[[-
A tree farm program. Place a chest under the turtle and run the program after giving it saplings.
It'll place trees on all four sides, and turn to check if any is grown every 10 seconds.
Note that the program doesn't take care of fuel in any way. If it's running low, terminate the program and refuel the turtle manually.
]]

local function cleanInv()
    for i = 16, 2, -1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            if turtle.getItemDetail().name:match("_sapling") then
                if not (turtle.transferTo(1) and turtle.transferTo(1)) then
                    turtle.dropDown()
                end
            else
                turtle.dropDown()
            end
        end
    end
    turtle.select(1)
end

local function up()
    if turtle.detect() then
        turtle.dig()
    end
    if turtle.detectUp() then
        turtle.digUp()
    end
    turtle.up()
end

local function chopDown()
    while true do
        local _, tBlockFront = turtle.inspect()
        if tBlockFront.tags["minecraft:logs"] then
            up()
        else
            break
        end
    end
    repeat
        turtle.down()
    until turtle.detectDown()
    cleanInv()
end


while true do
    os.setComputerLabel("Turtle "..os.getComputerID().." | Fuel: "..tostring(turtle.getFuelLevel()).." - Farming trees")

    local _, tBlockFront = turtle.inspect()
    if tBlockFront.tags["minecraft:logs"] then
        chopDown()
    end
    if not turtle.detect() then
        turtle.place()
    end
    sleep(10)
    turtle.turnRight()
end
