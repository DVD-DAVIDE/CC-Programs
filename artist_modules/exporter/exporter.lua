--[[
    exporter.lua by DVD-DAVIDE https://github.com/DVD-DAVIDE/CC-Programs
    Basically a fancy trashcan.lua which allows to specify a different output for each item.
    Useful for composters and similar.
]]

local log = require "artist.lib.log".get_logger(...)
local schema = require "artist.lib.config".schema

return function(context)
    local items = context:require("artist.core.items")
    local config = context.config
        :group("exporter", "Exporter module options")
        :define("rules",
            "Items to export and the conditions (e.g. {{item = 'minecraft:wheat_seeds', inv = 'minecraft:chest_2536', conditions = {maxKeep = 1024}}})",
            {}, schema.table)
        :get()

    local do_export = false
    local recently_exported = false
    local scan_timer

    for i, rule in pairs(config.rules) do
        if rule.inv and rule.inv ~= "" and peripheral.isPresent(rule.inv) then
            context:require("artist.items.inventories"):add_ignored_name(rule.inv)
            rule.enabled = true
            do_export = true
            log("Added rule %d (%s->%s)", i, rule.item, rule.inv)
        else
            log("Ignoring rule %d (%s->%s): invalid inventory", i, rule.item, rule.inv)
        end
    end

    local function queue_export()
        if scan_timer or not do_export then return end

        local delay = 5
        if recently_exported then delay = 0.4 end
        scan_timer = os.startTimer(delay)
    end

    context:spawn(function()
        while do_export do
            repeat local _, id = os.pullEvent("timer") until id == scan_timer
            recently_exported, scan_timer = false, nil

            for _, rule in pairs(config.rules) do
                if rule.enabled then
                    local item = items:get_item(rule.item)
                    local conditions = rule.conditions
                    local inv = rule.inv
                    local count = item.count
                    if count > 0 then
                        for condition_name, condition_value in pairs(conditions) do
                            if condition_name == "maxKeep" then
                                count = count - condition_value
                            else
                                -- Sorry, haven't implemented anything else yet.
                                count = 0
                            end
                        end
                    end
                    if count > 0 then
                        log("Exporting %d x %s to %s", count, rule.item, inv)
                        items:extract(inv, rule.item, count, nil, function (extracted)
                            if extracted == 0 then
                                if not peripheral.isPresent(inv) then
                                    rule.enabled = false
                                end
                            end
                        end)
                        recently_exported = true
                        break
                    end
                end
            end
        end
    end)

    if do_export then context.mediator:subscribe("items.change", function() queue_export() end) end
end
