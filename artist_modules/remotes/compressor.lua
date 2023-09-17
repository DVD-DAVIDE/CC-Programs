peripheral.find("modem", rednet.open)
rednet.host("artist.compressor", os.getComputerLabel() or "unnamed compressor")

local _, y_pos = term.getCursorPos()
local compressed, decompressed = 0, 0
local failure
local grid_slots = {}
local lookup_grid = {}

local function list()
    local inv = {}
    for i = 1, 16 do
        inv[i] = turtle.getItemDetail(i)
    end
    return inv
end

local function genGrid(n) 
    if n < 0 or n > 3 then error(("Grid size %d is out of range."):format(n), 2) end
    local l_grid = {}
    for i = 1, n do
        for j = 1, n do
            l_grid[(i - 1) * 4 + j] = true
        end
    end
    return l_grid
end

local function push_items_forward(slot_from, amount, slot_to)
    if not slot_to then slot_to = slot_from + 1 end
    turtle.select(slot_from)
    local original_count = turtle.getItemCount(slot_from)
    if not turtle.transferTo(slot_to, amount) then
        if slot_to == 16 then
            error("Not enough space.")
        end
        push_items_forward(slot_from, amount - original_count + turtle.getItemCount(slot_from), slot_to + 1)
    end
end

local function failed_compression(reason, recipient)
    failure = true
    local res = {
        reason = reason,
        items = {
            ret = list()
        }
    }
    rednet.send(recipient, res, "compress_failure")
end

local function successful_compression(orig_msg, recipient)
    local res = {
        amount = orig_msg.amount,
        items = {
            to_compress = orig_msg.item,
            to_collect = list()
        }
    }
    rednet.send(recipient, res, "compress_success")
end

while true do
    failure = false
    term.setCursorPos(1, y_pos)
    print(("Compressed items: %d"):format(compressed))
    print(("Decompressed items: %d"):format(decompressed))

    local sender, msg = rednet.receive("compress_order")
    local slots_to_use = msg.grid_size * msg.grid_size
    local items_received = 0
    for slot, item in pairs(list()) do
        if item.name ~= msg.item then
            failed_compression(("Sent items do not match order (%s ~= %s)"):format(item.name, msg.item), sender)
            break
        end
        items_received = items_received + item.count
    end
    if items_received ~= msg.amount then
        failed_compression(("Sent items do not match ordered amount (%d ~= %d)"):format(items_received, msg.amount), sender)
    end
    if slots_to_use > 1 and items_received % slots_to_use ~= 0 then
        failed_compression(("The amount of items sent does not match the grid size (%d %% %d = %d)"):format(items_received, slots_to_use, items_received % slots_to_use), sender)
    end
    if items_received > 64 * slots_to_use then
        failed_compression(("The amount of items sent exceeds how many can be stored in the specified grid (%d > 64 * %d)"):format(items_received, slots_to_use), sender)
    end

    if not failure then
        -- Spread items in the grid
        lookup_grid = genGrid(msg.grid_size)
        local items_per_slot = items_received / slots_to_use
        for i = 1, 16 do
            local inv = list()
            if inv[i] then
                local to_move = inv[i].count
                if lookup_grid[i] then
                    to_move = to_move - items_per_slot
                end
                push_items_forward(i, to_move)
            end
        end

        -- Craft
        turtle.select(1)
        local craft_success, reason = turtle.craft()
        if not craft_success then
            failed_compression(("Failed to craft item: %s"):format(reason), sender)
        else
            successful_compression(msg, sender)
            compressed = compressed + msg.amount
        end
    end
    failure = false
end
