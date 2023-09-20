rednet.open("right")
rednet.host("array.controller", "dvd_davide.chunk")

local clients = {}

print("Waiting for clients to connect... (Press Enter to stop scanning)")
parallel.waitForAny(
    read,
    function ()
        local f = function ()
            while true do
                local id, msg = rednet.receive("array.client")
                if id and msg.command == "connect" then
                    local connid = #clients + 1
                    table.insert(clients, connid, {
                        id = id,
                        pos = {},
                    })
                    rednet.send(id, {connectionid = connid}, "array.controller")
                    repeat
                        id, msg = rednet.receive("array.client", 10)
                    until not id or msg.connectionid == connid
                    if not id then table.remove(clients, connid)
                    else clients[connid].pos = msg.pos end
                end
                local _, cursor_y = term.getCursorPos()
                term.setCursorPos(1, cursor_y)
                write(("Connected clients: %d"):format(table.getn(clients)))
            end
        end
        parallel.waitForAll(f, f, f, f, f)
    end,
    function ()
        while true do
            local pings = {}
            for connid, client in pairs(clients) do
                table.insert(pings, function ()
                    rednet.send(client.id, {connectionid = connid, command = "ping"}, "array.controller")
                end)
            end
            parallel.waitForAll(table.unpack(pings), function() sleep(5) end)
        end
    end
)

print("\nStarting...")
local connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        rednet.send(client.id, {connectionid = connid, command = "start"}, "array.controller")
    end)
end
parallel.waitForAll(table.unpack(connections))

print("Started")
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        local id, msg
        repeat
            id, msg = rednet.receive("array.client")
        until id == client.id and msg.connectionid == connid and msg.command == "position_update"
        client.pos = msg.pos
    end)
end
parallel.waitForAll(table.unpack(connections))

local digging_y = -512
for _, client in pairs(clients) do
    if client.pos.y > digging_y then
        digging_y = client.pos.y
    end
end

print("Digging at y "..digging_y)
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        rednet.send(client.id, {connectionid = connid, command = "goto", pos = {y = digging_y}}, "array.controller")
    end)
end
parallel.waitForAll(table.unpack(connections))

connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        local id, msg
        repeat
            id, msg = rednet.receive("array.client")
        until id == client.id and msg.connectionid == connid and msg.command == "position_update"
        client.pos = msg.pos
    end)
end
parallel.waitForAll(table.unpack(connections))

print("All clients are in position.")
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        rednet.send(client.id, {connectionid = connid, command = "dig_base"}, "array.controller")
    end)
end
parallel.waitForAll(table.unpack(connections))
print("Digging the base.")
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        local id, msg
        repeat
            id, msg = rednet.receive("array.client")
        until id == client.id and msg.connectionid == connid and msg.command == "dig_base"
        client.pos = msg.pos
    end)
end
parallel.waitForAll(table.unpack(connections))
print("All done.")

print("Starting to dig the chunk.")
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        rednet.send(client.id, {connectionid = connid, command = "dig_chunk"}, "array.controller")
    end)
end
parallel.waitForAll(table.unpack(connections))
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        local id, msg
        repeat
            id, msg = rednet.receive("array.client")
        until id == client.id and msg.connectionid == connid and msg.command == "dig_chunk"
        client.pos = msg.pos
    end)
end
parallel.waitForAll(table.unpack(connections))
print("All done.")

print("Returning...")
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        rednet.send(client.id, {connectionid = connid, command = "Returning"}, "array.controller")
    end)
end
parallel.waitForAll(table.unpack(connections))
connections = {}
for connid, client in pairs(clients) do
    table.insert(connections, function ()
        local id, msg
        repeat
            id, msg = rednet.receive("array.client")
        until id == client.id and msg.connectionid == connid and msg.command == "return"
        client.pos = msg.pos
    end)
end
parallel.waitForAll(table.unpack(connections))
print("All returned")
