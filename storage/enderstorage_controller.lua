--[[-
    Ender Storage Controller by DVD-DAVIDE v1.0
    Program to change ender storage frequency.
    Supports both colors and numbers.
]]
--#region config
-- Change this to the side the Ender Storage is located at
-- Leave as nil if you want to search for it automatically with peripheral.find()
-- Please remember that peripheral.find() only works through a wired modem.
local side = nil
--#endregion config
--#region imports
local completion = require("cc.completion")
--#endregion imports
--#region constants
local CC_COLORS = {
    "white",
    "orange",
    "magenta",
    "lightBlue",
    "yellow",
    "lime",
    "pink",
    "gray",
    "lightGray",
    "cyan",
    "purple",
    "blue",
    "brown",
    "green",
    "red",
    "black",
}
--#endregion constants
--#region program
local history = {}
local enderstorage = peripheral.find("ender_storage")
if side then
    enderstorage = peripheral.wrap(side)
end
if not enderstorage then
    printError("Could not find any Ender Storage peripheral.")
    print("If it's directly attached to the computer, remember to set the 'side' variable to the side it's attached to.")
    return
end
if not enderstorage.areComputerChangesEnabled() then
    printError("The computer can't change the Ender Storage's frequency.")
    print("If it's on a private frequency, please make sure that computers can change it.")
    return
end

term.clear()
term.setCursorPos(1,1)
local continue
while true do
    continue = false
    print("Please input the frequency.")
    local input = read(nil, nil, function(text) return completion.choice(text:match("%S*$"), CC_COLORS, true) end)
    local freq_str =  table.pack(input:match("^(%S+)%s(%S+)%s(%S+)"))
    if #freq_str ~= 3 then
        printError("Wrong format. Use '<color> <color> <color>'.")
        continue = true
    end
    local freq = {}
    if not continue then
    for i, v in ipairs(freq_str) do
        if continue then break end
        if colors[v] then
            freq[i] = colors[v]
        elseif v:match("^%d+$") then
            freq[i] = tonumber(v)
        else
            printError("Invalid color: "..v)
            continue = true
        end
    end
    if not continue then
    enderstorage.setFrequency(table.unpack(freq))
    print("Frequency Set!\n")
    end end
end
--#endregion program