local tbl = require "artist.lib.tbl"
local log = require "artist.lib.log".get_logger(...)
local schema = require "artist.lib.config".schema

return function(context)
    local items = context:require("artist.core.items")
    local config = context.config
        :group("compressor", "Provide autocrafting for 1x1 and 3x3 shapeless recipes (such as iron ingots to blocks and vice versa).")
        :define("auto", "Items which should automatically be compressed. This is a mapping of hashes to the amount that should always be kept decompressed (e.g. {['minecraft:iron_ingot'] = 64})", {}, schema.table)
        :get()
    
    local compressor, compressor_addr
    local scan_timer
    
    local function queue_compressor()
        if scan_timer or not compressor then return end
        
        local delay = 5
        scan_timer = os.startTimer(delay)
    end
    
    context:spawn(function ()
        peripheral.find("modem", rednet.open)

        while true do
            local compressors = tbl.lookup({rednet.lookup("artist.compressor")})
            local compressor_peripheral = peripheral.find("turtle", function (name, p)
                return not tbl.rs_sides[name] and compressors[p.getID()] == true
            end)

            compressor = compressor_peripheral and peripheral.getName(compressor_peripheral)
            compressor_addr = compressor_peripheral.getID()
            log("Found compressor %s with rednet address %d", compressor, compressor_addr)

            queue_compressor()

            sleep(60)
        end
    end)

    context:spawn(function ()
        while true do
            repeat local _, id = os.pullEvent("timer") until  id == scan_timer
            scan_timer = nil

            if compressor and compressor_addr then
                for hash, limit in pairs(config.auto) do
                    local item = items:get_item(hash)
                    local extra = item.count - limit
                    if math.floor(extra / 9) > 0 then
                        extra = extra - (extra % 9)
                        log("Compressing %d x %s (sending to %s)", extra, hash, compressor)
                        items:extract(compressor, hash, extra, nil, function ()
                            local msg = {
                                grid_size = 3,
                                amount = extra,
                                item = hash
                            }
                            log("Debug: extra -> %d", extra)
                            log("Debug: msg -> %s", textutils.serialise(msg, {compact = true}))
                            rednet.send(compressor_addr, msg, "compress_order")
                            local sender, res, prot
                            repeat
                                sender, res, prot = rednet.receive(nil, 5)
                                if not sender then
                                    log("Compression response timed out.")
                                    break
                                end
                            until sender == compressor_addr and prot:match("^compress_")
                            if sender then
                                if prot == "compress_success" and res.amount == extra and res.items.to_compress == hash then
                                    log("Successfully compressed %d x %s", res.amount, res.items.to_compress)
                                    for slot, compressed_item in pairs(res.items.to_collect) do
                                        items:insert(compressor, slot, compressed_item)
                                    end
                                    return
                                elseif prot == "compress_failure" then
                                    log("Compressor %s failed to compress %d x %s for reason '%s'", compressor, extra, hash, res.reason)
                                    for slot, failed_item in pairs(res.items.ret) do
                                        items:insert(compressor, slot, failed_item)
                                    end
                                end
                            end
                        end)
                    --[[-
                    elseif extra < 0  then --Auto decompress. Dunno how to find the compressed item name.
                        local required = -math.ceil(extra / 9)
                    ]]
                    end
                end
            end
        end
    end)
end