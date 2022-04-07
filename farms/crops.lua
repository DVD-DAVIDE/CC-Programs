--[[-
This program is a fully automated farm.
It can be used on fields of many sizes and forms.
To setup the farm, place 'control' blocks at Y +3, as defined in the table 'controls' below.
If you're not planning to use wheat, you should also edit the crops data under the comment "Crops settings".
]]


--Check If Running On Turtle Computer
if not turtle then error('Must be a turtle.') return end

--Control Blocks Table. Edit block IDs only.
local controls = {
    right = 'minecraft:polished_andesite',
    left = 'minecraft:polished_granite',
    start = 'minecraft:polished_diorite'
}
--Crops settings
local cropGrownAge = 7
local seedName = 'minecraft:wheat_seeds'
local cropName = 'minecraft:wheat'

--Other variables. Do NOT edit
local progLoops, loopLength = 0, 0
local fuelNeeded = 500
local sleepTime = 120

--Replants crops
local function replant()
    local slot
    local loopCount = 1
    while turtle.getItemDetail().name ~= seedName do
        if loopCount == 1 then slot = 0 end
        if slot == 16 then
            print("Error: there aren't any seeds")
            return 1
        end
        slot = slot + 1
        turtle.select(slot)
        loopCount = loopCount + 1
    end
    if turtle.detectDown() then
        print('Error: there is a block down')
        return 2
    else
        turtle.placeDown()
        return 0
    end
end

--Check Crop Growth
local function checkGrowth()
    local replantSuccess = -1
    local isBlockDown, info = turtle.inspectDown()
    if isBlockDown then
        if info.name == cropName then
            if info.state.age == cropGrownAge then
                turtle.digDown()
                while replantSuccess ~= 0 do
                    replantSuccess = replant()
                    if replantSuccess == 1 then print('Waiting for seeds') sleep(10)
                    elseif replantSuccess == 2 then print('Remove the block!') sleep(10)
                    end
                end
                return 0
            elseif info.state.age < cropGrownAge then
                print('Crop not mature')
                return 1
            else
                print('Wrong crop age when mature set. Check it with F3.')
                return 2
            end
        else
            print('Wrong crop/block below')
            return 3
        end
    else
        print("There's nothing down!")
        return 4
    end
end

--Check Blocks Up
local function checkUp()
    local isBlockUp, info = turtle.inspectUp()
    if not isBlockUp then
        return 3
    else
        if info.name == controls.left then
            turtle.turnLeft()
            return 1
        elseif info.name == controls.right then
            turtle.turnRight()
            return 0
        elseif info.name == controls.start then
            progLoops = progLoops + 1
            return 4
        else
            return 2
        end
    end
end

--Check Fuel
local function checkFuel()
    local fuel = turtle.getFuelLevel()
    while fuel < fuelNeeded do
        print('Not enough fuel.')
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(0) then
                turtle.refuel()
                return
            end
        end
        fuel = turtle.getFuelLevel()
        if fuel < fuelNeeded then print('You need '..(fuelNeeded-fuel)..' more fuel') sleep(10) end
    end
    print('Successfully refuelled!')
    print('Current fuel level is '..fuel..'/'..fuelNeeded)
    return 0
end

--Empty Inventory
local function emptyInv()
    local x
    turtle.turnLeft()
    for i = 1, 16 do
        x = 17-i
        turtle.select(x)
        if turtle.getItemCount() > 0 then
            if turtle.getItemDetail().name == seedName then
                if x ~= 1 and not (turtle.transferTo(1) and turtle.transferTo(1)) then
                    turtle.drop()
                end
            else
                turtle.drop()
            end
        end
    end
    turtle.turnRight()
end

--Main Loop
while true do
    if checkGrowth() == 2 then return end
    local x = checkUp()
    if x == 0 then print('Right turn')
    elseif x == 1 then print('Left turn')
    elseif x == 4 then 
        if checkFuel() == 0 then print('Fuel ok') end
        emptyInv()
        print('Passed '..progLoops..' times from start')
        sleep(sleepTime)
    end
    if progLoops < 2 then loopLength = loopLength + 1
    elseif progLoops == 2 then
        if turtle.getFuelLimit() == 20000 then
            fuelNeeded = 2*loopLength
        elseif turtle.getFuelLimit() == 100000 then
            fuelNeeded = loopLength
        end
    end
    if not turtle.forward() then
        print('Path blocked. Check it is clear, or movement control blocks are placed right')
        return
    end
end
