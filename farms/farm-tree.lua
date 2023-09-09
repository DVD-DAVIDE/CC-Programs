--[[-
A tree farm program. Place a chest under the turtle and run the program after giving it saplings.
It'll place trees on all four sides, and turn to check if any is grown every 10 seconds.
]]

local MINFUEL = 100

local id, fuel

local function refuel()
    os.setComputerLabel(("Turtle %d | Fuel: %d - Refuelling"):format(id, fuel))
    turtle.select(2)
    while turtle.getItemCount() < 16 do
        os.setComputerLabel(("Turtle %d | Fuel: %d - Waiting for fuel"):format(id, fuel))
        sleep(10)
    end
    turtle.refuel()
    turtle.select(1)
end

local function cleanInv()
    for i = 16, 3, -1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            if turtle.getItemDetail().name:match("_sapling") then
                if not (turtle.transferTo(1) and turtle.transferTo(1)) then
                    turtle.dropDown()
                end
            elseif turtle.getItemDetail().name:match("_log") then
                if not (turtle.transferTo(2) and turtle.transferTo(2)) then
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
        local isBlockFront, tBlockFront = turtle.inspect()
        if isBlockFront and tBlockFront.tags["minecraft:logs"] then
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

id = os.getComputerID()

while true do
    fuel = turtle.getFuelLevel()
    if fuel < MINFUEL then
        refuel()
    end
    
    os.setComputerLabel(("Turtle %d | Fuel: %d - Farming trees"):format(id, fuel))
    turtle.select(1)

    local isBlockFront, tBlockFront = turtle.inspect()
    if isBlockFront and tBlockFront.tags["minecraft:logs"] then
        chopDown()
    end

    if not turtle.detect() then
        turtle.place()
    end
    sleep(10)
    turtle.turnRight()
end
