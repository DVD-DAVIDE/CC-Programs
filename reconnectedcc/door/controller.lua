local function open(relays)
    for _, relay in ipairs(relays) do
        relay.setOutput("top", false)
    end
end

local function close(relays)
    for _, relay in ipairs(relays) do
        relay.setOutput("top", true)
    end
end

local function door_controller()
    local relays = table.pack(peripheral.find("redstone_relay"))
    if #relays == 0 then
        error("No redstone relays found!", 0) --- IGNORE ---
    end
    while true do
        local e = table.pack(os.pullEvent("door_ctl"))
        repeat
            local refresh = true
            local command = e[2]
            local mode = e[3]
            if command == "open" then
                open(relays)
                if mode == "timeout" then
                    sleep(e[4] or 5)
                    os.queueEvent("door_ctl", "close", "immediate")
                end
            elseif command == "close" and mode == "timeout" then
                local timer = os.startTimer(e[4] or 1)
                repeat
                    e = table.pack(os.pullEvent())
                    if e[1] == "timer" and e[2] == timer then
                        close(relays)
                        break
                    elseif e[1] == "door_ctl" and e[2] == "open" then
                        refresh = false
                        break
                    end
                until true
            else
                close(relays)
            end
        until refresh
    end
end

return door_controller
