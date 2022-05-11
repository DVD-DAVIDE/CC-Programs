local modem = peripheral.wrap("back")
modem.closeAll()
print("Closed all channels")
print("Sniffing...")
local log_file = fs.open("log.log", "a")
local function log(msg, level)
    if level == nil then
        level = "info"
    end
    local to_log = ("[%s] %s"):format(level:upper(), msg)
    log_file.writeLine(to_log)
    log_file.flush()
    print(to_log)
end

local args = {...}
local channels = {
    rednet.CHANNEL_BROADCAST,
    rednet.CHANNEL_REPEAT,
    gps.CHANNEL_GPS,
    1234
}
local function open_modem(tbl)
    for _k, v in pairs(tbl) do
        local ch = v
        if type(v) == "string" then
            ch = tonumber(v)
        end
        modem.open(ch)
    end
end

open_modem(channels)
open_modem(args)

while true do
    local _event, side, channel, repl_channel, message, distance = os.pullEvent("modem_message")
    message = textutils.serialize(message)



    print(("%s (%d) - %d:%d - %s"):format(side, distance, channel, repl_channel, message ))
end

log("Program Terminated")
log_file.close()