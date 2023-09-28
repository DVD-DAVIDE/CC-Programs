while true do
    local _, side = os.pullEvent("peripheral")
    if side == "front" and peripheral.hasType(side, "ender_storage") then
        local es = peripheral.wrap(side)
        local a, b, c = es.getFrequency()
        if not (a == 1 and b == 1 and c == 1) then
            if es.areComputerChangesEnabled() then
                es.setFrequency(1, 1, 1)
            else
                print("Cannot change frequency, the enderstorage could be private.")
            end
        end
        if turtle and turtle.dig then
            turtle.dig()
            turtle.drop()
        end
    end
end