local modem = peripheral.find("modem")
local tArgs = {...}
local connect_to = {}
local instructions = {}

--[[
            Work In Progress!
    This allows passing a command to the program.
    It will not open the interactive shell, but instead it will execute the command and then end.
    For example, executing
        control.lua 5 3 9 turtle move forward 2
    will order turtles 5, 3, 9 to move two blocks forward and print the responses.
]]
--[[
if #tArgs > 0 then
    local connect_ids_completed = false
    for k, v in pairs(tArgs) do
        if v:match("^%d+$") and not connect_ids_completed then
            table.insert(connect_to, tonumber(v))
        elseif v:match("^[%w-_]+$") and #connect_to >= 1 then
            connect_ids_completed = true
            table.insert(instructions, v)
        else
            local program_name = arg[0] or fs.getName(shell.getRunningProgram())
            printError(("Error: bad argument #%d"):format(k))
            print("Usage: "..program_name.." <id> ... <command> <arg> ...")
            return
        end

    end
end
]]

if not modem or not modem.isWireless() then
    printError("An attached wireless modem is requierd.")
    return
end

local commands = {
    help = true,
    connect = false,
    disconnect = false,
    turtle = {
        move = {
            forward = false,
            back = false,
            up = false,
            down = false,
        },
        turn = {
            left = false,
            right = false,
        },
        dig = {
            forward = false,
            up = false,
            down = false,
        },
        place = {
            forward = false,
            up = false,
            down = false,
        },
        drop = {
            forward = false,
            up = false,
            down = false,
        },
        select = false,
        getItemCount = false,
        getItemSpace = false,
        detect = {
            forward = false,
            up = false,
            down = false,
        },
        compare = {
            forward = false,
            up = false,
            down = false,
        },
        attack = {
            forward = false,
            up = false,
            down = false,
        },
        suck = {
            forward = false,
            up = false,
            down = false,
        },
        getFuelLevel = false,
        refuel = false,
        compareTo = false,
        transferTo = false,
        getSelectedSlot = false,
        getFuelLimit = false,
        equip = {
            left = false,
            right = false,
        },
        inspect = {
            forward = false,
            up = false,
            down = false,
        },
        getItemDetail = false,
        craft = false,
    },
    "",
    "",
    "",
    "",
}

local func_list = {}
local function load_func_list(table_load, table_edit, parent)
    if not parent then
        parent = ""
    else
        parent = parent.."."
    end
    for key, value in pairs(table_load) do
        local value_type = type(value)
        if value_type == "boolean" and value then
            table_edit[#table_edit+1] = parent..key
        elseif value_type == "table" then
            load_func_list(value, table_edit, parent..key)
        end
    end
end
load_func_list(commands, func_list)

local help_list = {}
local function load_help_list(table_load, table_edit)
    for key, value in pairs(table_load) do
        local value_type = type(value)
        if value_type == "boolean" and value then
            table_edit[#table_edit+1] = key
        elseif value_type == "table" then
            table_edit[#table_edit+1] = ("[%s]"):format(key)
        end
    end
end
load_help_list(commands, help_list)

print(textutils.serialise(help_list))