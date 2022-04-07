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