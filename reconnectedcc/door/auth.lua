local function load(path)
    path = path or "/.passwd"
    if fs.exists(path) then
        local file = fs.open(path, "r")
        if not file then
            return nil
        end
        local content = file.readAll()
        file.close()
        return textutils.unserialise(content)
    else
        return nil
    end
end

local function hash(data)
    if security ~= nil then
        return security.hashStrSHA256(data)
    end
    local hashfunc = require("door.hash").hash256
    return hashfunc(data)
end

local function saveLogins(logins, path)
    path = path or "/.passwd"
    local file = fs.open(path, "w")
    if not file then
        printError("Failed to save password hashes!")
        return false
    end
    file.write(textutils.serialize(logins, { compact = true }))
    file.close()
    return true
end

local function auth_service()
    local logins = load()
    if logins == nil or logins.pw == nil or logins.nfc == nil or logins.rfid == nil
        or (logins.pw == {} and logins.nfc == {} and logins.rfid == {}) then
        error("No authentication settings found!", 0)
    end
    while true do
        repeat
            local event = table.pack(os.pullEvent("auth_check"))
            local method = event[2]
            local data = { table.unpack(event, 3) }
            if method == "password" then
                local user = data[1]
                local pass = hash(data[2])
                if logins.admin.username == user and logins.admin.pass == pass then
                    os.queueEvent("auth_result", true)
                    os.queueEvent("log", "auth_success", "admin")
                    ADMIN_MODE = true
                    return
                end
                if logins.pw[user] == nil then
                    os.queueEvent("auth_result", false, "Invalid username or password.")
                    os.queueEvent("log", "auth_fail", user, "Unknown username.")
                    break
                end
                local login = logins.pw[user]
                if login.pass ~= pass then
                    login.fail_attempts = (login.fail_attempts or 0) + 1
                    if login.fail_attempts >= 10 then
                        login.expires = 0
                        os.queueEvent("log", "auth_lockout", user, "Too many failed attempts.")
                    end
                    saveLogins(logins)
                    os.queueEvent("auth_result", false, "Invalid username or password.")
                    os.queueEvent("log", "auth_fail", user, "Invalid password.")
                    break
                end
                if login.expires and login.expires < os.epoch("utc") then
                    os.queueEvent("auth_result", false, "Password expired.")
                    os.queueEvent("log", "auth_fail", user, "Expired password.")
                    break
                end
                if login.uses ~= nil then
                    if login.uses <= 0 then
                        os.queueEvent("auth_result", false, "No remaining uses for this password.")
                        os.queueEvent("log", "auth_fail", user, "Password with no remaining uses.")
                        break
                    end
                    login.uses = login.uses - 1
                    saveLogins(logins)
                end
                os.queueEvent("auth_result", true)
                os.queueEvent("door_ctl", "open", 5, user, "Password")
            elseif method == "nfc" then
                local key = hash(data[1])
                if logins.nfc[key] == nil then
                    os.queueEvent("log", "auth_fail", key:sub(-10), "Unknown NFC card.")
                    break
                end
                local card = logins.nfc[key]
                if card.expires and card.expires < os.epoch("utc") then
                    os.queueEvent("log", "auth_fail", key:sub(-10), "NFC card Expired.")
                    break
                end
                if card.uses ~= nil then
                    if card.uses <= 0 then
                        os.queueEvent("log", "auth_fail", key:sub(-10), "NFC card with no remaining uses.")
                        break
                    end
                    card.uses = card.uses - 1
                    saveLogins(logins)
                end
                os.queueEvent("door_ctl", "open", 5, key:sub(-10), "NFC")
            elseif method == "rfid" then
                local key = hash(data[1])
                if logins.rfid[key] == nil then
                    break
                end
                local badge = logins.rfid[key]
                if badge.expires and badge.expires < os.epoch("utc") then
                    os.queueEvent("log", "auth_fail", key:sub(-10), "Expired RFID badge.")
                    break
                end
                os.queueEvent("door_ctl", "open", 1.5, key:sub(-10), "RFID")
            end
        until true
    end
end

return auth_service
