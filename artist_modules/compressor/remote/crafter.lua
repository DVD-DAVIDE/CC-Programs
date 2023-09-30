peripheral.find("modem", rednet.open)
rednet.host("artist.crafter", os.getComputerLabel() or "unnamed compressor")

while true do
  local ids = {}
  local sender, msg, total = nil, nil, nil
  repeat
    sender, msg = rednet.receive("crafter")
    if msg.done == "craft" then
      if not total then
        total = msg.total
      elseif total ~= msg.total then
        sleep(2)
        rednet.send(sender, "failure: wrong data sent.", "crafter_response")
      end
      ids[#ids+1] = msg.id
    end
  until msg.done == "craft" and #ids == total
  local res
  local ok, reason = turtle.craft()
  if ok then
    res = "success."
  else
    res = "failure: "..reason
  end
  rednet.send(sender, res, "crafter_response")
end
