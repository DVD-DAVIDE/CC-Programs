local side_fuel = "ender_storage_6957"
local side_items = "ender_storage_6952"
local side_output = "ender_storage_6956"

local fuels = {
    ["minecraft:bamboo"] = 0.25,
    ["minecraft:dried_kelp_block"] = 20,
}

local furnaces = {}
for i, periph in ipairs({peripheral.find("minecraft:furnace")}) do
    furnaces[i] = {}
    furnaces[i].inv = {}
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

local inv_fuel = peripheral.wrap(side_fuel)
local inv_items = peripheral.wrap(side_items)
local inv_output = peripheral.wrap(side_output)

inv_fuel.slots = {}

if not inv_fuel or not inv_items or not inv_output then
    printError("Can't find a chest.")
    return
end

if #furnaces == 0 --[[and #smokers == 0 and #blast_furnaces == 0]] then
    printError("There are no furnaces attached.")
    return
end

local tasks = {}

local function getFirstSlot(p)
    for slot, item in pairs(p.list()) do
        if item.count > 0 and not p.slots[slot] then
            return slot, item.count
        end
    end
    return nil
end

local function queue_refuel(furn)
    local slot, count = getFirstSlot(inv_fuel)
    if slot then
        inv_fuel.slots[slot] = true
        tasks[#tasks+1] = function ()
            inv_fuel.pushItems(furn.name, slot, count, 2)
            inv_fuel.slots[slot] = false
        end
    end
end

local function queue_collect(furn)
    tasks[#tasks+1] = function ()
        inv_output.pullItems(furn.name, 3)
    end
end

local function queue_smelt(furn, slot, count)
    tasks[#tasks+1] = function ()
        inv_items.pushItems(furn.name, slot, count, 1)
    end
end

local function update(furns)
    for _, f in pairs(furns) do
        f.inv = f.p.list()
        if f.inv[3] then queue_collect(f) end
        if f.inv[2] then
            if f.inv[1] then
                f.state = "smelting"
            else
                f.state = "idle"
            end
        else queue_refuel(f) end
    end
end

while true do
    update(furnaces)
    --update(smokers)
    --update(blast_furnaces)
    for slot, item in pairs(inv_items.list()) do
        for _, f in pairs(furnaces) do
            if f.state == "idle" and f.inv[2] then
                queue_smelt(f, slot, item.count)
                f.state = "smelting"
                break
            end
        end
    end

    if #tasks > 0 then
        parallel.waitForAll(table.unpack(tasks))
    else sleep(2.5) end
    tasks = {}
end