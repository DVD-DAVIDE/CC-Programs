local tbl = require "artist.lib.tbl"
local log = require "artist.lib.log".get_logger(...)
local schema = require "artist.lib.config".schema

local crafting_grid = {
    1, 2, 3, 5, 6, 7, 9, 10, 11,
}

return function(context)
    local config = context.config
        :group("compressor", "Compressor module options")
        :define("items", "Items which should be kept in a compressed state. For example {{decompressed = 'minecraft:iron_ingot', compressed = 'minecraft:iron_block', keep = 128}}", {}, schema.table)
        :get()
    local items = context:require("artist.core.items")

    local compressor
    local scan_timer

    local function queue_compressor()
        if scan_timer or not compressor then return end
        
        local delay = 5
        scan_timer = os.startTimer(delay)
    end

    context:spawn(function ()
        peripheral.find("modem", rednet.open)

        while true do
            local compressors = tbl.lookup({rednet.lookup("artist.crafter")})
            local compressor_peripheral = peripheral.find("turtle", function (name, p)
                return not tbl.rs_sides[name] and compressors[p.getID()] == true
            end)
            compressor = {}
            compressor.p  = compressor_peripheral and peripheral.getName(compressor_peripheral)
            compressor.id = compressor_peripheral.getID()
            log("Found compressor %s with rednet address %d", compressor.p, compressor.id)

            queue_compressor()

            sleep(60)
        end
    end)

    context:spawn(function ()
        while true do
            repeat local _, id = os.pullEvent("timer") until  id == scan_timer
            scan_timer = nil

            if compressor.p and compressor.id then
                for _, details in pairs(config.items) do
                    local item = items:get_item(details.decompressed)
                    local extra = item.count - details.keep
                    if extra < 0 then
                        -- Decompress
                        log("Compressing %d x %s", extra, details.decompressed)
                        local to_move = math.ceil(-extra / 9)
                        items:extract(compressor.p, details.compressed, to_move, 1)
                    elseif math.floor(extra / 9) > 0 then
                        -- Compress
                        extra = extra - (extra % 9)
                        log("Compressing %d x %s", extra, details.decompressed)
                        local to_move = extra / 9
                        for _, slot_to in ipairs(crafting_grid) do
                            items:extract(compressor.p, details.decompressed, to_move, slot_to)
                        end
                    end
                    rednet.send(compressor.id, "craft", "crafter")
                    local sender, res
                    repeat
                        sender, res = rednet.receive("crafter_response", 10)
                        if not sender then
                            log(("Compressor %s timed out."):format(compressor.p))
                            compressor = nil
                            break
                        end
                    until sender == compressor.id
                    if sender then
                        if res == "success" then
                            -- Handle success
                            log("Compression succeeded.")
                        elseif res == "failure" then
                            -- Handle failure
                            log("Compression failed.")
                        end
                        for i = 1, 16 do
                            items:insert(compressor.id, i, 64)
                        end
                    end
                end
            end
        end
    end)
end