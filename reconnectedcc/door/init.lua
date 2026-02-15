local login_interfaces = require("door.login_interfaces")
local logger = require("door.logger")
local auth_service = require("door.auth")
local door_controller = require("door.controller")

function string.random(len)
	math.randomseed(os.clock() ^ 5)
	local s = ""
	for _ = 1, len do
		s = s .. string.char(math.random(33, 126))
	end
	return s
end

function string:strip()
	assert(type(self) == "string", "Expected string for strip method")
	return self:match("^%s*(.-)%s*$")
end

local function hash(data)
	if security ~= nil then
		return security.hashStrSHA256(data)
	end
	local hashfunc = require("door.hash").hash256
	return hashfunc(data)
end

local function setup()
	local logins = {
		admin= {},
		pw = {},
		nfc = {},
		rfid = {},
	}
	local file = fs.open("/.passwd", "w")
	if not file then
		error("Failed to create password file!", 0)
	end

	print("No password file found. Setting up new authentication data.")

	write("Adding an admin user.\n")
	write("Username: ")
	local user = read()
	write("Password: ")
	local pass = hash(read("*"))
	logins.admin.username = user
	logins.admin.pass = pass


	write("Add a new user? (y/n): ")
	while read():sub(1, 1):lower() == "y" do
		write("Username: ")
		local user = read()
		write("Password: ")
		local pass = hash(read("*"))
		logins.pw[user] = { pass = pass }

		write("Password expiration time #{s/m/h/d/w/M/y} (default never): ")
		local exp, unit = read():strip():match("^(%d+)([smhdwMy]?)$")
		if exp and tonumber(exp) > 0 then
			if unit == "" or unit == nil then
				unit = "d"
			end
			local multiplier = 1
			if unit == "s" then
				multiplier = 1
			elseif unit == "m" then
				multiplier = 60
			elseif unit == "h" then
				multiplier = 3600
			elseif unit == "d" then
				multiplier = 86400
			elseif unit == "w" then
				multiplier = 604800
			elseif unit == "M" then
				multiplier = 2592000
			elseif unit == "y" then
				multiplier = 31536000
			end
			exp = tonumber(exp) * multiplier
			logins.pw[user].expires = os.epoch("utc") + exp * 1000
			print("Password will expire in " .. exp .. " seconds.")
		end

		write("Maximum uses for this password (default unlimited): ")
		local uses = tonumber(read():strip())
		if uses and uses > 0 then
			logins.pw[user].uses = uses
			print("Password will have " .. uses .. " uses.")
		end

		write("Add another user? (y/n): ")
	end

	write("Add an NFC card? (y/n): ")
	while read():sub(1, 1):lower() == "y" do
		local nfc = peripheral.find("nfc_reader")
		if not nfc then
			printError("No NFC reader found!")
			break
		end

		local key = string.random(128)
		write("Card label (default key): ")
		local label = read():match("%S+") or "key"
		print("Please place the NFC card on the reader...")
		nfc.write(key, label)

		key = hash(key)
		local _, _, success, reason = os.pullEvent("nfc_write")
		if success then
			logins.nfc[key] = {}
			print("NFC card added successfully!")
		else
			printError("Failed to write to NFC card: " .. reason)
		end

		write("Card expiration time #{s/m/h/d/w/M/y} (default never): ")
		local exp, unit = read():strip():match("^(%d+)([smhdwMy]?)$")
		if exp and tonumber(exp) > 0 then
			if unit == "" or unit == nil then
				unit = "d"
			end
			local multiplier = 1
			if unit == "s" then
				multiplier = 1
			elseif unit == "m" then
				multiplier = 60
			elseif unit == "h" then
				multiplier = 3600
			elseif unit == "d" then
				multiplier = 86400
			elseif unit == "w" then
				multiplier = 604800
			elseif unit == "M" then
				multiplier = 2592000
			elseif unit == "y" then
				multiplier = 31536000
			end
			exp = tonumber(exp) * multiplier
			logins.nfc[key].expires = os.epoch("utc") + exp * 1000
			print("Card will expire in " .. exp .. " seconds.")
		end

		write("Maximum uses for this card (default unlimited): ")
		local uses = tonumber(read():strip())
		if uses and uses > 0 then
			logins.nfc[key].uses = uses
			print("Card will have " .. uses .. " uses.")
		end

		write("Add another NFC card? (y/n): ")
	end

	write("Add a RFID badge? (y/n): ")
	while read():sub(1, 1):lower() == "y" do
		local nfc = peripheral.find("nfc_reader")
		if not nfc then
			printError("No NFC reader found!")
			break
		end

		local key = string.random(128)
		write("Card label (default key): ")
		local label = read():match("%S+") or "key"
		print("Please place the RFID badge on the reader...")
		nfc.write(key, label)
		key = hash(key)
		local _, _, success, reason = os.pullEvent("nfc_write")
		if success then
			logins.rfid[key] = {}
			print("RFID badge added successfully!")
		else
			printError("Failed to write to RFID badge: " .. reason)
		end

		write("Badge expiration time #{s/m/h/d/w/M/y} (default never): ")
		local exp, unit = read():strip():match("^(%d+)([smhdwMy]?)$")
		if exp and tonumber(exp) > 0 then
			if unit == "" or unit == nil then
				unit = "d"
			end
			local multiplier = 1
			if unit == "s" then
				multiplier = 1
			elseif unit == "m" then
				multiplier = 60
			elseif unit == "h" then
				multiplier = 3600
			elseif unit == "d" then
				multiplier = 86400
			elseif unit == "w" then
				multiplier = 604800
			elseif unit == "M" then
				multiplier = 2592000
			elseif unit == "y" then
				multiplier = 31536000
			end
			exp = tonumber(exp) * multiplier
			logins.rfid[key].expires = os.epoch("utc") + exp * 1000
			print("Badge will expire in " .. exp .. " seconds.")
		end

		write("Add another RFID badge? (y/n): ")
	end

	file.write(textutils.serialize(logins, { compact = true }))
	file.close()
end

local function admin_mode()
	print("Admin console.")
	return
end

local function main()
	if not fs.exists("/.passwd") then
		setup()
	end
	parallel.waitForAny(
		logger,
		auth_service,
		door_controller,
		login_interfaces.password,
		login_interfaces.nfc,
		login_interfaces.rfid,
		login_interfaces.button("redstone_relay_561", "back")
	)
end

os.pullEvent = os.pullEventRaw
ADMIN_MODE = false
local ok, err = pcall(main)

if not ok then
	printError("An error occurred: " .. tostring(err))
end

if ADMIN_MODE then
	admin_mode()
end

printError("Restarting in 5 seconds...")
sleep(5)
os.reboot()
