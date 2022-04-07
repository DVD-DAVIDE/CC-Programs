--[[-
This program is similar to 'go' from the shell, but also includes digging actions.
However, it isn't as flexible as it should be to accomplish more complex operations.
It was made just for digging obsidian.
]]


if not turtle then printError("Must be a turtle!") return end

local tArgs = {...}

if #tArgs == 0 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: "..programName.." <action> ...")
    return
end

local function forward()
    while not turtle.forward() do
        if not turtle.dig() then
            turtle.attack()
        end
    end
end

local function backwards()
    turtle.turnLeft()
    turtle.turnLeft()
    forward()
    turtle.turnLeft()
    turtle.turnLeft()
end

local function up()
    while not turtle.up() do
        if not turtle.digUp() then
            turtle.attackUp()
        end
    end
end

local function down()
    while not turtle.down() do
        if not turtle.digDown() then
            turtle.attackDown()
        end
    end
end

local function left()
    turtle.turnLeft()
    forward()
end

local function right()
    turtle.turnRight()
    forward()
end

local function digLeft()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
end

local function digRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnLeft()
end

local tActions = {
    ["f"] = forward,
    ["b"] = backwards,
    ["d"] = down,
    ["u"] = up,
    ["l"] = left,
    ["r"] = right,
    ["dl"] = digLeft,
    ["dr"] = digRight
}

if tArgs[1] == "-h" or tArgs[1] == "--help" then
    print(textutils.serialise(tActions))
    return
end

for _, sAction in pairs(tArgs) do
    tActions[sAction]()
end