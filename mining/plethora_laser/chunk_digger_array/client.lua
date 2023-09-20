local laser = peripheral.wrap("right")
rednet.open("left")

local pos, starting_y
local function update_position()
    local x, y, z = gps.locate()
    pos = {
        x = x,
        y = y,
        z = z,
    }
end

local id, msg_in, msg_out, conn_id
local function wait_for_instructions()
    while true do
        id, msg_in = rednet.receive("array.controller", 10)
        if not id then break end
        if msg_in.recipient == os.getComputerID() then
            break
        end
    end
end

local function forward()
    if not turtle.forward() then return false end
    update_position()
    return true
end
local function back()
    if not turtle.back() then return false end
    update_position()
    return true
end
local function down()
    if not turtle.down() then return false end
    update_position()
    return true
end
local function up()
    if not turtle.up() then return false end
    update_position()
    return true
end
local function fire(yaw, pitch, potency, times)
    if not times then times = 1 end
    for _ = 1, times do
        laser.fire(yaw, pitch, potency)
    end
end

local controller = rednet.lookup("array.controller", "dvd_davide.chunk")

if not laser then
    print("Can't find laser.")
    return
end

if not controller then
    print("Can't find the controller.")
    return
end

if turtle.getFuelLevel() < 500 then
    print("The minimum amount of fuel required is 500.")
    print("Not enough fuel.")
    return
end


msg_out = { command = "connect" , }
rednet.send(controller, msg_out, "array.client")

wait_for_instructions()
if not (id and msg_in.connectionid) then
    print("The controller isn't accepting the connection.")
    return
end
conn_id = msg_in.connectionid

local yaw_forward
update_position()
starting_y = pos.y
local t_x, t_z = pos.x, pos.z
forward()
yaw_forward = math.atan2(t_x - pos.x, t_z - pos.z)
back()
t_x, t_z = nil, nil

msg_out = {
    connectionid = conn_id,
    command = "position_update",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")

repeat
    wait_for_instructions()
    if not (id and msg_in.connectionid) then
        print("The request timed out. Closing connection.")
        return
    end
until msg_in.connectionid == conn_id and msg_in.command == "start"

fire(0, 90, 5, 200)

while down() do end

msg_out = {
    connectionid = conn_id,
    command = "position_update",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")

repeat
    wait_for_instructions()
    if not (id and msg_in.connectionid) then
        print("The request timed out. Closing connection.")
        return
    end
until msg_in.connectionid == conn_id and msg_in.command == "goto"

while msg_in.pos.y > pos.y do
    up()
end

msg_out = {
    connectionid = conn_id,
    command = "position_update",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")
local depth = starting_y - pos.y


repeat
    wait_for_instructions()
    if not (id and msg_in.connectionid) then
        print("The request timed out. Closing connection.")
        return
    end
until msg_in.connectionid == conn_id and msg_in.command == "dig_base"

fire(yaw_forward, 0, 5, 15)

msg_out = {
    connectionid = conn_id,
    command = "dig_base",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")

repeat
    wait_for_instructions()
    if not (id and msg_in.connectionid) then
        print("The request timed out. Closing connection.")
        return
    end
until msg_in.connectionid == conn_id and msg_in.command == "dig_chunk"

for _ = 1, 15 do
    forward()
    fire(0, -90, 5, depth)
end

msg_out = {
    connectionid = conn_id,
    command = "dig_chunk",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")

repeat
    wait_for_instructions()
    if not (id and msg_in.connectionid) then
        print("The request timed out. Closing connection.")
        return
    end
until msg_in.connectionid == conn_id and msg_in.command == "return"

for _ = 1, 15 do back() end
for _ = 1, depth do up() end

msg_out = {
    connectionid = conn_id,
    command = "return",
    pos = pos
}
rednet.send(controller, msg_out, "array.client")
