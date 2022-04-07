if not pcall(require, "veinMine") then
    printError("veinMine isn't present. Downloading...")
    shell.run("wget", "https://raw.githubusercontent.com/DVD-DAVIDE/CC-Programs/main/mining/autominer/veinMine.lua")
end

local veinMine = require "veinMine"

if not turtle then
    printError("Must be a turtle to run!")
    return
end

local nBlocksMoved = 0
local nMovementMultiplier = 2
if term.isColor() then nMovementMultiplier = 1 end

local function checkFuel()
    return turtle.getFuelLevel() > (nBlocksMoved + 25) * nMovementMultiplier
end

local function checkInvSpace()
    return turtle.getItemCount(16) == 0
end

local function forward()
    while not turtle.forward() do
        turtle.dig()
    end
    nBlocksMoved = nBlocksMoved + 1
end

local function goBack()
    turtle.turnLeft()
    turtle.turnLeft()
    for _ = 1, nBlocksMoved do
        forward()
    end
    turtle.turnLeft()
    turtle.turnLeft()
end


while true do
    if (not checkFuel()) or (not checkInvSpace()) then
        goBack()
        break
    end
    veinMine()
    forward()
end