local function password()
	while true do
		term.clear()
		term.setCursorPos(1, 1)
		write("Login: ")
		local user = read()
		write("Password: ")
		local pass = read("*")
		os.queueEvent("auth_check", "password", user, pass)
		local _, success, reason = os.pullEvent("auth_result")
		if success then
			print("Login successful! Door opening...")
		else
			printError("Login failed: " .. reason)
			sleep(5)
		end
		sleep(1)
	end
end

local function nfc()
	while true do
		local _, side, data = os.pullEvent("nfc_data")
		os.queueEvent("auth_check", "nfc", data, side)
	end
end

local function rfid()
	while true do
		local scanner = peripheral.find("rfid_scanner")
		if not scanner then
			error("No RFID scanner found!", 0)
		end
		local scan = scanner.scan()
		for _, item in ipairs(scan) do
			os.queueEvent("auth_check", "rfid", item.data, item.distance)
		end
		sleep(0.5)
	end
end

local function button(relay_name, side)
	assert(type(relay_name) == "string")
	assert(type(side) == "string")
	while true do
		local relay = assert(peripheral.wrap(relay_name), "Couldn't connect to the relay!")
		local signal = relay.getAnalogInput(side)
		if signal > 0 then
			os.queueEvent("log", "inner_button", nil, "Button pressed")
			os.queueEvent("door_ctl", "open", 5)
		end
		sleep(0.5)
	end
end

return {
	password = password,
	nfc = nfc,
	rfid = rfid,
	button = function(name, side)
		return function()
			return button(name, side)
		end
	end,
}
