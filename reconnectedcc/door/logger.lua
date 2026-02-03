local function logger()
    if not fs.exists("/logs") then
        fs.makeDir("/logs")
    end
    local path = "/logs/" .. os.date("%Y%m%d") .. ".log"
    local logfile = fs.open(path, "a")
    if not logfile then
        error("Failed to open log file!", 0)
    end
    logfile.writeLine("=== LOG STARTED ===")
    logfile.flush()
    while true do
        local e = table.pack(os.pullEvent("log"))
        local _, _, module, event = e[2]:find("^(%a+)_(.+)")
        if module and event then
            module = module:upper()
            event = event:upper()
            local timestamp = os.date("%Y%m%dT%H:%M:%S")
            local logline = string.format("[%s] [%s:%s] (%s) %s", timestamp, module, event, e[3] or "", table.concat(e, " ", 4))
            logfile.writeLine(logline)
            logfile.flush()
        end
    end
end

return logger