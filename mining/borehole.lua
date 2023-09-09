--[[
    borehole.lua by DVD-DAVIDE (Github https://github.com/DVD-DAVIDE/CC-Programs)
    Digs a vertical 1x1 hole in the ground, checking all four surrounding walls for ores.
    The ores to excavate are declared in the 'excavate' array below. edit as you wish.
]]

--Constants
local MINFUEL = 200
local MODE = 0
local GENERAL_ORE_TAG = "c:ores"


if not turtle then printError("Must be a turtle to run!") return end

-- Checks fuel amount
local fuel = turtle.getFuelLevel()
if fuel < MINFUEL then print(("Not enough fuel: %d/%d."):format(fuel, MINFUEL)) return end
fuel = math.floor(fuel/2)
local depth, maxdepth = 0, 0

local excavate = {
    ["minecraft:coal_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:copper_ore"] = true,
    ["minecraft:lapis_ore"] = true,
    ["minecraft:gold_ore"] = true,
    ["minecraft:redstone_ore"] = true,
    ["minecraft:diamond_ore"] = true,
    ["minecraft:emerald_ore"] = true,
    ["minecraft:deepslate_coal_ore"] = true,
    ["minecraft:deepslate_iron_ore"] = true,
    ["minecraft:deepslate_copper_ore"] = true,
    ["minecraft:deepslate_lapis_ore"] = true,
    ["minecraft:deepslate_gold_ore"] = true,
    ["minecraft:deepslate_redstone_ore"] = true,
    ["minecraft:deepslate_diamond_ore"] = true,
    ["minecraft:deepslate_emerald_ore"] = true,
    ["minecraft:obsidian"] = true
}

local function down()
    while not turtle.down() do
        if turtle.detectDown() then
            if not turtle.digDown() then
                print(("Reached Bedrock at depth %d. Returning."):format(maxdepth))
                fuel = 0
                return
            end
        elseif turtle.attackDown() then
            while turtle.attackDown() do end
        end
    end
    fuel = fuel - 1
    depth = depth + 1
    if maxdepth < depth then maxdepth = depth end
end

local function up()
    while not turtle.up() do
        if turtle.detectUp() then
            if not turtle.digUp() then
                print("What the Fuck?!")
                fuel = 0
                return
            end
        elseif turtle.attackUp() then
            while turtle.attackUp() do end
        end
    end
end

local function returnToDepth(d)
    for i = 1, d do
        down()
    end
end

local function checkExcavate()
    local det, block = turtle.inspect()
    if not det then return false end
    if MODE == 1 and block.tags[GENERAL_ORE_TAG] then return true end
    if excavate[block.name] then return true end
end

local function toSurface()
    while depth > 0 do
        turtle.up()
        depth = depth - 1
    end
end

local function dumpInventory()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

dumpInventory()

while fuel > 0 do
    down()
    for _ = 1, 4, 1 do
        if checkExcavate() then
            turtle.dig()
        end
        turtle.turnRight()
    end
    if turtle.getItemCount(16) > 0 then
        toSurface()
        dumpInventory()
        if fuel < maxdepth then
            print("Fuel is not enought to return to previous excavation depth. Stopping.")
            fuel = 0
        else
            returnToDepth(maxdepth)
        end
    end
end

toSurface()
dumpInventory()

print(("Excavated down to depth %d."):format(maxdepth))
