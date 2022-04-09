local geo = peripheral.find("geoScanner")
local arguments = {...}
local scan_radius = 8
if #arguments == 1 then
    scan_radius = arguments[1]
end

if not geo then
    printError("A geoscanner is required.")
    return
end

if not turtle then
    printError("A turtle is required.")
    return
end

local wanted_list = {
    ["minecraft:gold_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:coal_ore"] = true,
    ["minecraft:nether_gold_ore"] = true,
    ["minecraft:lapis_ore"] = true,
    ["minecraft:diamond_ore"] = true,
    ["minecraft:redstone_ore"] = true,
    ["minecraft:emerald_ore"] = true,
    ["minecraft:nether_quartz_ore"] = true,
    ["powah:uraninite_ore_poor"] = true,
    ["powah:uraninite_ore"] = true,
    ["powah:uraninite_ore_dense"] = true,
    ["powah:dry_ice"] = true
}

local item_list = {
    ["minecraft:gold_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:coal"] = true,
    ["minecraft:lapis_lazuli"] = true,
    ["minecraft:diamond"] = true,
    ["minecraft:redstone"] = true,
    ["minecraft:emerald"] = true,
    ["powah:uraninite_raw_poor"] = true,
    ["powah:uraninite_raw"] = true,
    ["powah:uraninite_raw_dense"] = true,
    ["powah:dry_ice"] = true
}

local to_mine = {}
local mined = {}
local pos = { x = 0, y = 0, z = 0 }
local dir = { x = nil, z = nil }
local original_dir = dir
local unique_block = "minecraft:netherrack"

local log_file = fs.open(("%s.d/logs/%d.log"):format(fs.getName(shell.getRunningProgram()):match("^[^%.]+"), math.floor(os.epoch("utc") / 1000)), "w")
local log_file_latest = fs.open(("%s.d/logs/latest.log"):format(fs.getName(shell.getRunningProgram()):match("^[^%.]+")), "w")
local function log(msg, level)
    if level == nil then
        level = "info"
    end
    log_file.writeLine(("[%s] %s"):format(level:upper(), msg))
    log_file.flush()
    log_file_latest.writeLine(("[%s] %s"):format(level:upper(), msg))
    log_file_latest.flush()
end

local function checkInvSpace()
    local unloaded = 0
    local unloadedSlots = 0
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if not item_data then
            return true
        elseif not (item_list[item_data.name] or item_data.name == unique_block) then
            turtle.select(i)
            turtle.drop()
            unloaded = unloaded + item_data.count
            unloadedSlots = unloadedSlots + 1
            if unloadedSlots >= 2 then
                break
            end
        end
        sleep(1)
    end
    turtle.select(1)
    if unloaded > 0 then
        log(("Unloaded %d junk items"):format(unloaded))
        return true
    else
        log("Inventory full", "fatal")
        return false
    end
end

local function place_unique_block()
    local found = false
    if turtle.detect() then
        turtle.dig()
    end
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 and turtle.getItemDetail(i)["name"] == unique_block then
            turtle.select(i)
            found = true
            break
        end
    end
    if found then
        turtle.place()
        turtle.select(1)
        return true
    else
        printError("No "..unique_block.." found.\nStopping the program.")
        log("No "..unique_block.." found.", "fatal")
        turtle.select(1)
        return false
    end
end

local function forward()
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end
    pos.x = pos.x + dir.x
    pos.z = pos.z + dir.z
    mined[pos.x.."-"..pos.y.."-"..pos.z] = true
end

local function up()
    while not turtle.up() do
        if not turtle.digUp() then
            turtle.attackUp()
        end
    end
    pos.y = pos.y + 1
    mined[pos.x.."-"..pos.y.."-"..pos.z] = true
end

local function down()
    while not turtle.down() do
        if not turtle.digDown() then
            turtle.attackDown()
        end
    end
    pos.y = pos.y - 1
    mined[pos.x.."-"..pos.y.."-"..pos.z] = true
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

local function scan(radius)
    while true do
        local scan_cooldown = geo.getOperationCooldown("scanBlocks")
        if scan_cooldown == 0 then
            break
        end
        sleep(0.2)
    end
    local res = geo.scan(radius)
    log(("Scan: %d blocks in a radius of %d"):format(#res, radius))
    return res
end

local function turn_dir(dir_x, dir_z)
    if dir.x ~= dir_x or dir.z ~= dir_z then
        while dir.x ~= dir_x do
            left()
        end
        while dir.z ~= dir_z do
            left()
        end
        log(("New direction: x = %d, z = %d"):format(dir_x, dir_z))
    end
end

local function go_to(x, y, z)
    while true do
        local dist = { x = x - pos.x, y = y - pos.y, z = z - pos.z}
        if dist.x > 0 then
            turn_dir(1, 0)
            forward()
        elseif dist.x < 0 then
            turn_dir(-1, 0)
            forward()
        elseif dist.y > 0 then
            up()
        elseif dist.y < 0 then
            down()
        elseif dist.z > 0 then
            turn_dir(0, 1)
            forward()
        elseif dist.z < 0 then
            turn_dir(0, -1)
            forward()
        end
        if dist.x == 0 and dist.y == 0 and dist.z == 0 then
            break
        end
    end
    log(("Moved to x = %d, y = %d, z = %d"):format(x, y, z))
end


if not place_unique_block() then
    return
end
local test_res = scan(1)
turtle.dig()
for _, info in ipairs(test_res) do
    if info.name == unique_block then
        dir.x, dir.z = info.x, info.z
        break
    end
end
original_dir.x, original_dir.z = dir.x, dir.z
log(("Original direction: x = %d, z = %d"):format(original_dir.x, original_dir.z))
local res = scan(scan_radius)
for _, info in ipairs(res) do
    if wanted_list[info.name] then
        table.insert(to_mine, {name = info.name, pos = {x = info.x, y = info.y, z = info.z}})
        log(("Found %s at x = %d, y = %d, z = %d"):format(info.name, info.x, info.y, info.z))
    end
end
log(("Found %d total blocks"):format(#to_mine))
for _, block in ipairs(to_mine) do
    if not checkInvSpace() then
        print("Inventory full. Stopping.")
        break
    end
    if not mined[block.pos.x.."-"..block.pos.y.."-"..block.pos.z] then
        go_to(block.pos.x, block.pos.y, block.pos.z)
        log(block.name..(" at x = %d, y = %d, z = %d mined"):format(block.pos.x, block.pos.y, block.pos.z))
    else
        log(block.name..(" at x = %d, y = %d, z = %d was already mined"):format(block.pos.x, block.pos.y, block.pos.z))
    end
end
go_to(0, 0, 0)
turn_dir(original_dir.x, original_dir.z)

log("End of log")
log_file.close()