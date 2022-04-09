--[[
    Program for an infinite-space item storage using the Item Digitizer.
    Requires mod BPeripherals.

    Due to a BPeripherals bug, this program won't work if you don't first use the Item Digitizer digitize() function at least once.
    To do this, place any item in the digitizer, then run the following lines in the lua interpreter:
        -- Mandatory:
            digitizer = peripheral.find("item_digitizer")
            x = digitizer.digitize()
        -- Only if you want your item back:
            digitizer.rematerialize(x)
        -- To close the interpreter:
            exit()

    The program is actually under testing and DOES NOT work properly.
    Do not use it on a survival world or with anything you wouldn't want to lose.
]]

pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local digitizer = peripheral.find("item_digitizer")

local barrels = peripheral.find("minecraft:barrel")

if not digitizer then
    print("Couldn't find any digitizer!")
    return
end

local data2, data1, data = nil, nil, nil
local lastUnloadedData = ""

local items = {}
if fs.exists(".items") then
    local itemsLoadFile = fs.open(".items", "r")
    items = textutils.unserialise(itemsLoadFile.readAll())
    itemsLoadFile.close()
end

local function addItem(nItem)
    items[#items+1] = (nItem or digitizer.digitize())
end

local function autoadd()
    while true do
        data2 = data1
        data1 = data
        data = textutils.serialiseJSON({digitizer.data()})
        print(data)
        print("Are vars different: "..tostring(lastUnloadedData ~= data))
        if (data ~= "{}" and data ~= lastUnloadedData) and (data == data1 and data == data2) then
            addItem()
        end
        sleep(0.5)
    end
end

local function extract()
    while true do
        local nID = tonumber(read())
        local nItemId = items[nID]
        if nItemId then
            lastUnloadedData = textutils.serialiseJSON({digitizer.dataID(nItemId)})
            digitizer.rematerialize(table.remove(items, nID))
        end
    end
end

local function safeTerminate()
    return os.pullEventRaw("terminate") == "terminate"
end

parallel.waitForAny(autoadd, extract, safeTerminate)

local itemsFile = fs.open(".items", "w")
itemsFile.write(textutils.serialise(items))
itemsFile.close()

local varsFile = fs.open("vars.txt", "w")
varsFile.write(textutils.serialise({data2, data1, data, lastUnloadedData}))
varsFile.close()