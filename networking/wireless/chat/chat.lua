local username = "";
local curPos = "1"
local channel = "0"
local x, y = term.getSize()
local xzentral = x / 2
local yzentral = y / 2
local modemside
local inty
local nickname, cursorold


local function joinChannel()
        term.clear()
        term.setCursorPos(xzentral - 4, yzentral)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        textutils.slowWrite("Join channel: ")
        channel = read()

        if channel == "" then term.setCursorPos(12, 10)
                term.clearLine()
                print("Error: Please enter a Channelname ! ")
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                os.sleep(1)
                joinChannel()
        else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.setCursorPos(xzentral - 4, yzentral)
                term.clearLine()
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                term.setCursorPos(xzentral - 4, yzentral)
                textutils.slowWrite("Joining channel...")
                os.sleep(1)
                rednet.broadcast("*** " .. username .. " joined the chat ***", channel)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                return
        end
end

local function menu()
        fs.delete("/chatfolder")
        term.clear()

        if curPos == "1" then

                term.clear()
                term.setCursorPos(xzentral - 4, yzentral - 1)
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                print("Join channel")
                term.setCursorPos(xzentral - 4, yzentral)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Settings")
                term.setCursorPos(xzentral - 4, yzentral + 1)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Quit")
                local event, key = os.pullEvent("key")

                if key == 208
                then


                        curPos = "2"
                        menu()

                elseif key == 28
                then
                        joinChannel()
                        return
                else menu()
                end
        end


        if curPos == "2" then
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setBackgroundColor(colors.black)
                term.setCursorPos(xzentral - 4, yzentral - 1)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Join channel")
                term.setCursorPos(xzentral - 4, yzentral)
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                print("Settings")
                term.setCursorPos(xzentral - 4, yzentral + 1)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Quit")
                term.setBackgroundColor(colors.black)
                local event, key = os.pullEvent("key")
                if key == 200
                then
                        curPos = "1"
                        menu()


                elseif key == 208
                then
                        term.setBackgroundColor(colors.black)
                        curPos = "3"
                        menu()

                elseif key == 28
                then
                        nickname()
                else menu() term.setBackgroundColor(colors.black)
                end
        end


        if curPos == "3" then
                term.clear()
                term.setCursorPos(xzentral - 4, yzentral - 1)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Join channel")
                term.setCursorPos(xzentral - 4, yzentral)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                print("Settings")
                term.setCursorPos(xzentral - 4, yzentral + 1)
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                print("Quit")

                local event, key = os.pullEvent("key")
                if key == 200
                then
                        curPos = "2"
                        menu()

                elseif key == 28
                then
                        term.setBackgroundColor(colors.black)
                        term.setTextColor(colors.white)
                        term.clear()
                        term.setCursorPos(xzentral - 4, yzentral)
                        textutils.slowPrint("Good Bye")
                        term.setCursorPos(1, 1)
                        os.sleep(2)
                        os.shutdown()

                else term.clear() term.setBackgroundColor(colors.black) menu()
                end
        end
end

local function close()
        local _event, _button, xPos, yPos = os.pullEvent("mouse_click")
        if xPos == 50 and yPos == 1 then term.clear() menu() end
end

nickname = function ()
        term.clear()
        term.setCursorPos(14, 10)
        write("Username:")
        username = read();
        if username == "" then term.setCursorPos(12, 10) term.clearLine() print("Error: Please enter a Username ! ") os.sleep(2) nickname() else
                term.clear()
                term.setCursorPos(12, 9)
                print("-------------------------------")
                term.setCursorPos(12, 11)
                print("-------------------------------")
                term.setCursorPos(16, 10)
                textutils.slowPrint("Username:" .. username .. " saved")
                os.sleep(2)
        end
end

local chat = "";

local function writetoscreen(text)
        term.clear()
        local h = fs.open("/chatfolder/LOG-" .. channel..".log", "a")
        h.writeLine(text);
        h.flush();
        h.close();
        cursorold()
        local g = fs.open("/chatfolder/LOG-" .. channel..".log", "r");
        print(g.readAll());
        g.close()
end

local function oldmessages()
        cursorold()
        local l = fs.open("/chatfolder/chat" .. channel, "r");
        print(l.readAll());
        l.close()

end

local function writetoscreen_local(text)
        term.clear()
        local h = fs.open("/chatfolder/chat" .. channel, "a")
        h.writeLine("[" .. username .. "]" .. ":" .. text);
        h.flush();
        h.close();
        cursorold()
        local g = fs.open("/chatfolder/chat" .. channel, "r");
        print(g.readAll());
        g.close()
end

local function cursornew()
        _, inty = term.getSize();
        term.setCursorPos(1, inty)
end

cursorold = function()
        term.setCursorPos(1, 2)
end

local function getSide()
        for _, side in ipairs({ "top", "bottom", "front", "left", "right", "back" }) do
                if peripheral.isPresent(side) then
                        if peripheral.getType(side) == "modem" then
                                modemside = side
                                rednet.open(modemside)
                        end
                end
        end
end

local function send()
        cursornew()
        term.clearLine()
        term.setCursorPos(1, inty - 1)
        term.setCursorPos(1, 1)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        write("---You are chatting in channel " .. channel .. "---             ")
        term.setCursorPos(x - 2, 1)
        write("[X]")
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1, inty - 1)
        print("---------------------------------------------------")
        cursornew()
        write("Text:")
        local msg = read();
        term.clearLine()
        cursornew()
        term.clear()
        if msg == "" then oldmessages() else
                chat = chat .. msg
                cursorold()
                writetoscreen_local(msg)
                rednet.broadcast("[" .. username .. "]" .. ":" .. msg, channel)
                cursornew()
                term.clearLine()
        end
end

local function receive()
        local _id, message, _protocol = rednet.receive(channel)
        cursorold()
        chat = chat .. message
        writetoscreen(message)
end

fs.delete("chat")
getSide();
nickname()
menu()


term.clear()


while true do
        parallel.waitForAny(send, receive, close)
end
