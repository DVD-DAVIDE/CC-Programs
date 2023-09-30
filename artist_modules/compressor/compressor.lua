local tbl = require "artist.lib.tbl"
local log = require "artist.lib.log".get_logger(...)
local schema = require "artist.lib.config".schema

local crafting_grid = {
    1, 2, 3, 5, 6, 7, 9, 10, 11,
}

local function extractfunction(rec, slot, total, amount)
    local msg = {
        id = slot,
        total = total,
        amount = amount,
        done = "craft",
    }
    return function ()
        rednet.send(rec, msg, "crafter")
    end
end

return function(context)
    local config = context.config
        :group("compressor", "Compressor module options")
        :define("items", "Items which should be kept in a compressed state. For example {{decompressed = 'minecraft:iron_ingot', compressed = 'minecraft:iron_block', keep = 128}}", {}, schema.table)
        :get()
    local items = context:require("artist.core.items")

    local compressor
    local recently_compressed, scan_timer

    local function queue_compressor()
        if scan_timer or not compressor then return end
        
        local delay = 5
        if recently_compressed then delay = 0.4 end
        scan_timer = os.startTimer(delay)
    end

    context:spawn(function ()
        peripheral.find("modem", rednet.open)

        while true do
            local compressors = tbl.lookup({rednet.lookup("artist.crafter")})
            local compressor_peripheral = peripheral.find("turtle", function (name, p)
                return not tbl.rs_sides[name] and compressors[p.getID()] == true
            end)
            if compressor_peripheral then
                compressor = {}
                compressor.p  = compressor_peripheral and peripheral.getName(compressor_peripheral)
                compressor.id = compressor_peripheral.getID()
                log("Found compressor %s with rednet address %d", compressor.p, compressor.id)
            end

            queue_compressor()

            sleep(60)
        end
    end)

    context:spawn(function ()
        while true do
            repeat local _, id = os.pullEvent("timer") until  id == scan_timer
            recently_compressed, scan_timer = false, nil

            if compressor and compressor.p and compressor.id then
                for _, details in pairs(config.items) do
                    local collect_results = false
                    local item = items:get_item(details.decompressed)
                    local extra = item.count - details.keep
                    if math.abs(extra) > 576 then extra = extra / extra * 576 end
                    if extra < 0 then
                        -- Decompress
                        item = items:get_item(details.compressed)
                        extra = -extra
                        if extra > 9 * item.count then extra = 9 * item.count end
                        if extra > 0 then
                            log("Decompressing %d x %s", extra, details.decompressed)
                            local to_move = math.ceil(extra / 9)
                            items:extract(compressor.p, details.compressed, to_move, 1, extractfunction(compressor.id, 1, 1, to_move))
                            collect_results = true
                        else
                            log("Can't decompress %s: not enough items in inventory.", details.compressed)
                        end
                    elseif extra >= 9 then
                        -- Compress
                        local to_move = math.floor(extra / 9)
                        log("Compressing %d x %s", to_move * 9, details.decompressed)
                        local tasks = {}
                        for _, slot_to in ipairs(crafting_grid) do
                            tasks[#tasks+1] = function ()
                                items:extract(compressor.p, details.decompressed, to_move, slot_to, extractfunction(compressor.id, slot_to, 9, to_move))
                            end
                        end
                        parallel.waitForAll(table.unpack(tasks))
                        collect_results = true
                    end
                    if collect_results then
                        local sender, res = nil, nil
                        repeat
                            sender, res = rednet.receive("crafter_response", 10)
                            if not sender then
                                log("Compressor %s timed out.", compressor.p)
                                compressor = nil
                                break
                            end
                        until sender == compressor.id
                        if sender then
                            log("Compression: %s", res)
                            for i = 1, 16 do
                                items:insert(compressor.p, i, 64)
                            end
                        end
                        recently_compressed = true
                    end
                end
            end
        end
    end)

    context.mediator:subscribe("items.change", function () queue_compressor() end)
end
