local function open(relays, ...)
    for _, relay in ipairs(relays) do
        relay.setOutput("top", false)
    end
    os.queueEvent("log", "door_opened", ...)
end

local function close(relays, ...)
    for _, relay in ipairs(relays) do
        relay.setOutput("top", true)
    end
    os.queueEvent("log", "door_closed", ...)
end

local function door_controller()
    local relays = table.pack(peripheral.find("redstone_relay"))
    if #relays == 0 then
        error("No redstone relays found!", 0) --- IGNORE ---
    end
    local timer = nil
    while true do
        local e = table.pack(os.pullEvent())
        if e[1] == "timer" and e[2] == timer then
            close(relays, table.unpack(e, 4))
            timer = nil
        elseif e[1] == "door_ctl" then
            if e[2] == "open" then
                if timer == nil then
                    open(relays, table.unpack(e, 4))
                end
                timer = os.startTimer(e[3] or 5)
            else
                close(relays, table.unpack(e, 4))
            end
        end
    end
end

return door_controller
