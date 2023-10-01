if not chatbox.hasCapability("tell") then
    error("Computer doesn't have 'tell' capability.")
end
local args = {...}
shell.run(...)
chatbox.tell(chatbox.getLicenseOwner(), "**Program** '*"..table.concat(args, " ").."*' **has finished running.**", "FinishAlert", nil)
