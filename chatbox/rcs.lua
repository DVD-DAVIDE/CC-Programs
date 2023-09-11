if not chatbox.hasCapability("command") or not chatbox.hasCapability("tell") then
	error("Chatbox does not have the required permissions. Did you register the license?")
end

local id = os.getComputerID()
local label = os.getComputerLabel()

local BOT_NAME = (turtle and "Turtle-" or "Computer-")..(label or id)

local owner = chatbox.getLicenseOwner()

while true do
    local event, user, command, args = os.pullEvent("command")

    if command == "rcs" and user == owner then
        if #args == 0 then
            chatbox.tell(user, "Select this computer with \\rcs "..(label or id), BOT_NAME)
        end
        if args[1] == label or args[1] == tostring(id) then
            table.remove(args, 1)
            shell.run(args)
        end
    end
end