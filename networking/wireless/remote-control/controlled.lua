local modem = peripheral.find("modem")
local tArgs = {...}

if #tArgs ~= 1 then
    local program_name = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: "..program_name.." <controller_id>")
    return
end


if not modem or not modem.isWireless() then
    printError("An attached wireless modem is requierd.")
    return
end

