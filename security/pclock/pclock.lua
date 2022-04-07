local logins = require("logins")

local loggedIn = false

repeat
    term.clear()
    term.setCursorPos(1,1)

    print("Insert user:")
    local user = read()
    print("Insert password:")
    local pass = read("*")

    if logins[user] == pass then
        loggedIn = true
    else
        print("Wrong user or password.")
        sleep(2)
    end
until loggedIn