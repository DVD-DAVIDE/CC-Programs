local logger_print = true
local output_side = "front"
local modem_side = "bottom"

local input = peripheral.find("inventory", function (name)
    local ok, ret = pcall(peripheral.call, modem_side, "isPresentRemote", name)
    return ok and ret
end)
local turtle_name = peripheral.call(modem_side, "getNameLocal")

local crafting_grid = {
    1, 2, 3, 5, 6, 7, 9, 10, 11,
}

local drop = {
    ["front"] = turtle.drop,
    ["top"] = turtle.dropUp,
    ["bottom"] = turtle.dropDown,
}

local function log(...)
    if logger_print then
        print(...)
    end
end

local function get_legal_slot()
    for _, slot in ipairs(crafting_grid) do
        if turtle.getItemSpace(slot) > 0 then
            return slot
        end
    end
    return nil
end

local function get_total(item_name)
    local count = 0
    for _, item in pairs(input.list()) do
        if item.name == item_name then
            count = count + item.count
        end
    end
    return count
end

local function push_items_forward(from_slot, keep)
    turtle.select(from_slot)
    while turtle.getItemCount(from_slot) > keep do
        local to_move = turtle.getItemCount(from_slot) - keep
        local to_slot
        for _, slot in ipairs(crafting_grid) do
            if slot > from_slot and turtle.getItemSpace(slot) > 0 then to_slot = slot break end
        end
        if not to_slot then error("This bad.") end
        turtle.transferTo(to_slot, to_move)
    end
    turtle.select(1)
end

local function get_last_used_slot()
    for i = 16, 1, -1 do
        if turtle.getItemCount(i) > 0 then
            return i
        end
    end
    return nil
end

while true do
    local slot = get_last_used_slot()
    if not slot then break end
    input.pullItems(turtle_name, slot)
end

while true do
    local current_item = nil
    local item_count = 0
    log("Input inventory:")
    for slot, item in pairs(input.list()) do
        log(("Slot %d: %d x %s"):format(slot, item.count, item.name))
        if ((not current_item) or current_item == item.name) and get_legal_slot() and get_total(item.name) >= 9 then
            current_item = current_item or item.name
            while true do
                local details = input.getItemDetail(slot)
                local slot_to = get_legal_slot()
                if not details or details.name ~= current_item or not slot_to then break end
                item_count = item_count + input.pushItems(turtle_name, slot, turtle.getItemSpace(slot_to), slot_to)
            end
        end
    end
    if current_item then
        log(("%d x %s moved to turtle inventory."):format(item_count, current_item))
        log(("Crafting ..."))
            item_count = item_count - input.pullItems(turtle_name, get_last_used_slot(), item_count % 9)
            local items_per_slot = item_count / 9
            for _, slot in ipairs(crafting_grid) do
                push_items_forward(slot, items_per_slot)
            end
            turtle.craft()
            log("Done.")
        log("Clearing turtle inventory.")
        for i = 16, 1, -1 do
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                drop[output_side]()
            end
        end
    end
    if not current_item then sleep(5) end
end