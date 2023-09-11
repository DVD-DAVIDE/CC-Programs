--[[-
    Development of this program has been abandoned, as it isn't self-sustainable.
]]

if not turtle then error("Must be a turtle.") return end

local CROP_NAME = "minecraft:bamboo"
local MIN_FUEL = 10
local REFUEL_TO = 500

local right_next = false
local fuel = turtle.getFuelLevel()

local storage_blocks = {
    "minecraft:hopper",
    "minecraft:chest",
    "minecraft:trapped_chest",
    "minecraft:barrel",
    "minecraft:.*shulker_box"
}
-- Check if array 'table' contains 'value'
---@param table table
---@param value any
---@return boolean
local function has_value(table, value)
    for _, v in ipairs(table) do
        if v == value then return true end
    end
    return false
end

-- Refuel the turtle up to the 'REFUEL_TO' level.
-- Returns wether the turtle was refuelled succesfully.
---@return boolean 
local function refuel()
    for i = 16, 1, -1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            if turtle.refuel(0) then turtle.refuel() end
            fuel = turtle.getFuelLevel()
            if fuel >= REFUEL_TO then
                return true
            end
        end
    end
    return false
end

-- Move forward, if a block is present destroy it.
-- If another entity is present, attack.
-- If it's impossible to remove the block then returns false.
---@return boolean
local function forward()
    while not turtle.forward() do
        if turtle.detect() then
            if not turtle.dig() then error("Unbreakable block in front.", 1) return false end
        else
            turtle.attack()
        end
    end
    fuel = fuel - 1
    return true
end

-- Decides wether to turn right, left or turn around to do another pass.
---@return boolean
local function turn()
    right_next = not right_next
    if right_next then
        turtle.turnRight()
        local block_present, block_info = turtle.inspect()
        if block_present and block_info.name ~= CROP_NAME then
            turtle.turnRight()
            return true
        end
        if not forward() then return false end
        turtle.turnRight()
        return true
    end
    turtle.turnLeft()
    local block_present, block_info = turtle.inspect()
    if block_present and block_info.name ~= CROP_NAME then
        turtle.turnRight()
        turtle.turnRight()
        if not forward() then return false end
        turtle.turnRight()
        right_next = true
        return true
    end
    if not forward() then return false end
    turtle.turnLeft()
    return true
end

-- Empties the inventory into an inventory placed below.
---@return boolean
local function unload()
    for i = 16, 2, -1 do
        turtle.select(i)
        turtle.dropDown()
    end
    turtle.select(1)
    return true
end

-- Suck items in front, on top and below
---@return nil
local function suck()
    turtle.suck()
    turtle.suckUp()
    local block_down_present, block_down_info = turtle.inspectDown()
    if block_down_present and not has_value(storage_blocks, block_down_info.name) then
        turtle.suckDown()
    end
end

-- Handles navigation.
---@return unknown
local function next()
    suck()
    local block_down_present, block_down_info = turtle.inspectDown()
    if block_down_present and has_value(storage_blocks, block_down_info.name) and turtle.getItemCount(2) > 0 then return unload() end
    local block_present, block_info = turtle.inspect()
    if not block_present or block_info.name == CROP_NAME then return forward() end
    return turn()
end

-- Main program loop
while next() do
    if fuel < MIN_FUEL then
        if not refuel() and fuel < MIN_FUEL then error("Not enough fuel.", 1) end
    end
end