local fuel_name = "ender_storage_6957"
local input_name = "ender_storage_6952"
local output_name = "ender_storage_6956"

local fuel_inv = peripheral.wrap(fuel_name)
local input_inv = peripheral.wrap(input_name)

--[[]]
local function time_func(func, ...)
    local t = os.clock()
    func(...)
    return os.clock() - t
end
--]]

local fuels = {
    ["minecraft:bamboo"] = {i = 1, f = 4},
    ["minecraft:dried_kelp_block"] = 20,
}

local slots = {
    input = 1,
    fuel = 2,
    output = 3,
}

local furnaces = {}
for i, periph in ipairs({peripheral.find("minecraft:furnace")}) do
    furnaces[i] = {}
    furnaces[i].p = periph
    furnaces[i].name = peripheral.getName(periph)
end
--[[]
local smokers = {}
for i, periph in ipairs({peripheral.find("minecraft:smoker")}) do
    smokers[i] = {}
    smokers[i].inv = {}
    smokers[i].p = periph
    smokers[i].name = peripheral.getName(periph)
end

local blast_furnaces = {}
for i, periph in ipairs({peripheral.find("minecraft:blast_furnace")}) do
    blast_furnaces[i] = {}
    blast_furnaces[i].inv = {}
    blast_furnaces[i].p = periph
    blast_furnaces[i].name = peripheral.getName(periph)
end
--]]
local input_ls
local fuel_ls

if not fuel_inv or not input_inv then
    printError("Can't find a chest.")
    return
end

if #furnaces == 0 --[[and #smokers == 0 and #blast_furnaces == 0]] then
    printError("There are no furnaces attached.")
    return
end

local tasks = {}

local function getFirstSlot(count)
    for slot, item in ipairs(fuel_ls) do
        item.reserved = item.reserved or 0
        local available = item.count - item.reserved
        if available > 0 then
            if available > count then available = count end
            return slot, available
        end
    end
    return nil
end

local function queue_refuel(f)
    local needed = f.p.getItemLimit(slots.fuel) - (f.fuel.count or 0)
    local slot, count = getFirstSlot(needed)
    if slot then
        fuel_ls[slot].reserved = fuel_ls[slot].reserved + count
        tasks[#tasks+1] = function ()
            fuel_inv.pushItems(f.name, slot, count, 2)
            fuel_ls[slot].reserved = fuel_ls[slot].reserved - count
        end
    end
end

local function queue_collect(furn)
    tasks[#tasks+1] = function ()
        furn.p.pushItems(output_name, slots.output)
    end
end

local function queue_smelt(furn, slot, count)
    tasks[#tasks+1] = function ()
        input_inv.pushItems(furn.name, slot, count, 1)
    end
end

local function update(furns)
    for _, f in pairs(furns) do
        local inv = f.p.list()
        f.input  = inv[1] or {}
        f.fuel   = inv[2] or {}
        f.output = inv[3] or {}
        if f.output.count then queue_collect(f) end

        -- Minimum fuel (chosen because some fuels can smelt .25, .34, .75 items (so 3*4))
        if f.fuel.count and f.fuel.count >= 12 then
            if f.input.count then
                f.state = "smelting"
            else
                f.state = "idle"
            end
        else queue_refuel(f) end
    end
end

local function find_furn(furns, name)
    for i, f in ipairs(furns) do
        f.input.reserved = f.input.reserved or 0
        if f.state == "smelting" and f.input.name == name and f.input.count + f.input.reserved < f.p.getItemLimit(slots.input) then
            local can_move = f.p.getItemLimit(slots.input) - f.input.count - f.input.reserved
            return i, can_move
        elseif f.state == "idle" then
            return i, 64
        end
    end
    return nil
end

while true do
    -- Somewhere something broke, but it's a lil better now so i'm keeping it this way
    input_ls = input_inv.list()
    fuel_ls = fuel_inv.list()
    --print(time_func(update, furnaces))
    update(furnaces)
    --update(smokers)
    --update(blast_furnaces)
    
    for slot, item in ipairs(input_ls) do
        item.reserved = 0
        while item.reserved < item.count do
            local furn_index, move = find_furn(furnaces, item.name)
            if furn_index then
                if move > item.count - item.reserved then
                    move = item.count - item.reserved
                end
                local f = furnaces[furn_index]
                queue_smelt(f, slot, move)
                f.input.reserved = (f.input.reserved or 0) + move
                item.reserved = (item.reserved or 0) + move
            else break end
        end
    end

    if #tasks > 0 then
        parallel.waitForAll(table.unpack(tasks))
        --print(time_func(parallel.waitForAll, table.unpack(tasks)))
    else sleep(2.5) end
    tasks = {}
end