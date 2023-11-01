local use_enderstorage = true
local log_to_stdout = true

if not turtle then
    printError("A turtle is required.")
    return
end

local scanner = peripheral.find("plethora:scanner")
if not scanner then
    printError("A Block Scanner is required (none found).")
    return
end

local args = {...}

local ores = {
    ["minecraft:diamond_ore"]            = true,
    ["minecraft:deepslate_diamond_ore"]  = true,
    ["minecraft:emerald_ore"]            = true,
    ["minecraft:deepslate_emerald_ore"]  = true,
    ["minecraft:gold_ore"]               = true,
    ["minecraft:deepslate_gold_ore"]     = true,
    ["minecraft:iron_ore"]               = true,
    ["minecraft:deepslate_iron_ore"]     = true,
    ["minecraft:redstone_ore"]           = true,
    ["minecraft:deepslate_redstone_ore"] = true,
    ["minecraft:lapis_ore"]              = true,
    ["minecraft:deepslate_lapis_ore"]    = true,
    ["minecraft:coal_ore"]               = true,
    ["minecraft:deepslate_coal_ore"]     = true,
}

local keep = {
    ["minecraft:diamond"] = true,
    ["minecraft:emerald"] = true,
    ["minecraft:raw_gold"] = true,
    ["minecraft:raw_iron"] = true,
    ["minecraft:redstone"] = true,
    ["minecraft:lapis_lazuli"] = true,
    ["minecraft:coal"] = true,
}

local pos = { x = 0, y = 0, z = 0 }
local dir = { x = nil, z = nil }

local function sign(n)
    if n > 0 then return 1 end
    if n < 0 then return -1 end
    return 0
end

local log_file        = fs.open(("%s.d/logs/%d.log"):format(fs.getName(shell.getRunningProgram()):match("^[^%.]+"), math.floor(os.epoch("utc") / 1000)), "w")
local log_file_latest = fs.open(("%s.d/logs/latest.log"):format(fs.getName(shell.getRunningProgram()):match("^[^%.]+")), "w")

local function log(msg, ...)
    local line = msg:format(...)
    log_file.writeLine(line)
    log_file.flush()
    log_file_latest.writeLine(line)
    log_file_latest.flush()
    if log_to_stdout then
        print(line)
    end
end

local function getFirstEmptySlot()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then return i end
    end
    return 17
end

local function shiftInvLeft()
    for i = 16, 1, -1 do
        if turtle.getItemCount(i) > 0 then
            if getFirstEmptySlot() < i then
                turtle.select(i)
                turtle.transferTo(getFirstEmptySlot())
            else
                break
            end
        end
    end
    turtle.select(1)
end

local function clearInv()
    local unloaded = 0
    if use_enderstorage then
        turtle.select(1)
        if turtle.detect() then turtle.dig() end
        turtle.place()
    end
    for i = 2, 16 do
        local item = turtle.getItemDetail(i)
        if item and (use_enderstorage or not keep[item.name]) then
            turtle.select(i)
            turtle.drop()
            unloaded = unloaded + item.count
        end
    end
    turtle.select(1)
    if use_enderstorage then turtle.dig() end
    shiftInvLeft()
    log("Cleared %d items", unloaded)
    return unloaded > 0
end

local mined = {}

local function forward()
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end
    pos.x = pos.x + dir.x
    pos.z = pos.z + dir.z
    mined[pos.x.."."..pos.y.."."..pos.z] = true
end

local function up()
    while not turtle.up() do
        if not turtle.digUp() then
            turtle.attackUp()
        end
    end
    pos.y = pos.y + 1
    mined[pos.x.."."..pos.y.."."..pos.z] = true
end

local function down()
    while not turtle.down() do
        if not turtle.digDown() then
            turtle.attackDown()
        end
    end
    pos.y = pos.y - 1
    mined[pos.x.."."..pos.y.."."..pos.z] = true
end

local function left()
    turtle.turnLeft()
    if dir.x ~= 0 then
        dir.z = -dir.x
        dir.x = 0
    else
        dir.x = dir.z
        dir.z = 0
    end
end

local scan = scanner.scan

local function turn_dir(dir_x, dir_z)
    if dir.x ~= dir_x or dir.z ~= dir_z then
        while dir.x ~= dir_x do
            left()
        end
        while dir.z ~= dir_z do
            left()
        end
        log("New direction: x = %d, z = %d", dir_x, dir_z)
    end
end

local function go_to(x, y, z)
    while x - pos.x ~= 0 do
        turn_dir(sign(x - pos.x), 0)
        forward()
    end

    while y - pos.y ~= 0 do
        if y > pos.y then
            up()
        else
            down()
        end
    end

    while z - pos.z ~= 0 do
        turn_dir(0, sign(z - pos.z))
        forward()
    end

    log("Moved to %d %d %d", pos.x, pos.y, pos.z)
end

turtle.select(1)
local name = turtle.getItemDetail().name
turtle.dig()
turtle.place()
for _, block in pairs(scanner.scan()) do
    if block.name == name and (block.x == 0 and math.abs(block.z) == 1 or block.z == 0 and math.abs(block.x) == 1) then
        dir.x, dir.z = block.x, block.z
        break
    end
end
turtle.dig()
local original_x, original_z = dir.x, dir.z
log("Starting direction: x = %d z = %d", dir.x, dir.z)

local to_mine = {}


for _, block in ipairs(scanner.scan()) do
    if ores[block.name] then
        table.insert(to_mine , {name = block.name, pos = {x = block.x, y = block.y, z = block.z}})
        log("Found %s at %d %d %d", block.name, block.x, block.y, block.z)
    end
end

log("Mining %d blocks", #to_mine)
for _, block in ipairs(to_mine) do
    if turtle.getItemCount(16) > 0 then
        if not clearInv() then
            log("Inventory full")
            break
        end
    end
    if not mined[block.pos.x.."."..block.pos.y.."."..block.pos.z] then
        go_to(block.pos.x, block.pos.y, block.pos.z)
        log("Mined %s at %d %d %d", block.name, block.pos.x, block.pos.y, block.pos.z)
    else
        log("Already mined %s at %d %d %d", block.name, block.pos.x, block.pos.y, block.pos.z)
    end
end

log("Returning")
go_to(0, 0, 0)
turn_dir(original_x, original_z)

log("Clearing inventory...")
clearInv()
log("Done")

log("End of log")
log_file.close()
log_file_latest.close()
