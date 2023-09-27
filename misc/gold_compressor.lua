local input = peripheral.find("inventory", function (name)
    return peripheral.call("front", "isPresentRemote", name)
end)
local turtle_name = peripheral.call("front", "getNameLocal")

local crafting_grid = {
    1, 2, 3, 5, 6, 7, 9, 10, 11,
}

local items_pull = {
    ["minecraft:gold_nugget"] = true,
    ["minecraft:gold_ingot"] = true,
}

local items_push_output = {
    ["minecraft:gold_block"] = true,
}

local items_transport_output = {
    ["minecraft:rotten_flesh"] = true,
    ["minecraft:gold_block"] = true,
}

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
    for slot, item in pairs(input.list()) do
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

for i = 16, 1, -1 do
    if turtle.getItemCount(i) > 0 then
        turtle.select(i)
        input.pullItems(turtle_name, i)
    end
end

while true do
    local current_item = nil
    local item_count = 0
    for slot, item in pairs(input.list()) do
        print("Loop1")
        if (((items_pull[item.name] and get_total(item.name) >= 9) or items_transport_output[item.name]) and not current_item) or current_item == item.name then
            current_item = item.name
            while input.list()[slot] do
                local to_slot = get_legal_slot()
                if to_slot then
                    item_count = item_count + input.pushItems(turtle_name, slot, turtle.getItemSpace(to_slot), to_slot)
                else break end
            end
        end
    end
    if current_item then
        print("ci")
        if items_pull[current_item] then
            print("craft")
            item_count = item_count - input.pullItems(turtle_name, 1, item_count % 9)
            local items_per_slot = item_count / 9
            for _, slot in ipairs(crafting_grid) do
                print("spread loop")
                push_items_forward(slot, items_per_slot)
            end
            turtle.craft()
        end
        for i = 16, 1, -1 do
            print("invclear loop")
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                local item = turtle.getItemDetail()
                if items_push_output[item.name] or items_transport_output[item.name] then
                    turtle.dropUp()
                else
                    input.pullItems(turtle_name, i)
                end
            end
        end
    end
    if not current_item then sleep(10) end
end