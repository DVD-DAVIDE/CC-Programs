local modem = peripheral.find("modem")

if not modem or not modem.isWireless() then
    printError("An attched wireless modem is requierd.")
    return
end

