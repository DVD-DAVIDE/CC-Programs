local manipulators = {peripheral.find("manipulator")}
if #manipulators == 0 then print("Connect at least one manipulator to the network.") return end
local tasks = {}

laser = {}
laser.YAW = 0
laser.PITCH = 0
laser.POTENCY = 0
laser.AMOUNT = 0

for _, man in ipairs(manipulators) do
    table.insert(tasks, function ()
        for i = 1, laser.AMOUNT do
            man.fire(laser.YAW, laser.PITCH, laser.POTENCY)
            print(("Firing shot #%d with dir. (%d,%d) and pot. %d."):format(i, laser.YAW, laser.PITCH, laser.POTENCY))
        end
    end)
end

local increment_yaw, increment_pitch, starting_yaw, starting_pitch, final_yaw, final_pitch
while true do
    term.clear()
    term.setCursorPos(1, 1)
    write("Insert starting yaw: ") starting_yaw = tonumber(read(nil, nil, nil, tostring(starting_yaw or "")))
    write("Insert final yaw: ") final_yaw = tonumber(read(nil, nil, nil, tostring(final_yaw or "")))
    write("Insert yaw increment: ") increment_yaw = tonumber(read(nil, nil, nil, tostring(increment_yaw or "")))
    write("Insert starting pitch: ") starting_pitch = tonumber(read(nil, nil, nil, tostring(starting_pitch or "")))
    write("Insert final pitch: ") final_pitch = tonumber(read(nil, nil, nil, tostring(final_pitch or "")))
    write("Insert pitch increment: ") increment_pitch = tonumber(read(nil, nil, nil, tostring(increment_pitch or "")))
    write("Insert potency: ") laser.POTENCY = tonumber(read(nil, nil, nil, tostring(laser.POTENCY or "")))
    write("Insert iterations: ") laser.AMOUNT = tonumber(read(nil, nil, nil, tostring(laser.AMOUNT or "")))
    if increment_pitch and increment_yaw and starting_pitch and starting_yaw and final_pitch and final_yaw then
        if (final_yaw - starting_yaw) * increment_yaw > 0 and (final_pitch - starting_pitch) * increment_pitch > 0 then
            for i = starting_pitch, final_pitch, increment_pitch do
                laser.PITCH = i
                for j = starting_yaw, final_yaw, increment_yaw do
                    laser.YAW = j
                    parallel.waitForAll(table.unpack(tasks))
                    if i == 90 or i == -90 then break end
                end
            end
            print("Done.")
        else
            print("The current settings will result in an infinite loop.")
        end
    else
        print("Invalid option(s).")
    end
    print("Run again (ENTER) or quit (any char)?")
    if read() ~= "" then break end
end
print("Goodbie.")