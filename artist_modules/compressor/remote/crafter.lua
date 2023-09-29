peripheral.find("modem", rednet.open)
rednet.host("artist.crafter", os.getComputerLabel() or "unnamed compressor")

local _, y_pos = term.getCursorPos()
local crafted = 0

while true do
  term.setCursorPos(1, y_pos)
  write(("Crafted %d items"):format(crafted))

  local sender, msg = rednet.receive("crafter")
  if msg == "craft" then
    local res
    if turtle.craft() then
        res = "success"
    else
        res = "failure"
    end
    rednet.send(sender, msg, "crafter_response")
  end
end
