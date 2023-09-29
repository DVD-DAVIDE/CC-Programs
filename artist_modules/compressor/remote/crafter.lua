peripheral.find("modem", rednet.open)
rednet.host("artist.crafter", os.getComputerLabel() or "unnamed compressor")

while true do
  local sender, msg = rednet.receive("crafter")
  if msg == "craft" then
    local res
    if turtle.craft() then
        res = "success"
    else
        res = "failure"
    end
    rednet.send(sender, res, "crafter_response")
  end
end
