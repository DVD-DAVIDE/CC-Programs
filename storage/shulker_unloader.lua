local shulker_side, output_side = "bottom", "top"

while true do
    local _, side = os.pullEvent("peripheral")
    if side == shulker_side then
        local shulker = peripheral.wrap(shulker_side)
        for slot, _ in pairs(shulker.list()) do
            shulker.pushItems(output_side, slot)
        end
        if turtle then
            turtle.select(1)
            if shulker_side == "bottom" then
                turtle.digDown()
            elseif shulker_side == "top" then
                turtle.digUp()
            elseif shulker_side == "front" then
                turtle.dig()
            end
            turtle.drop()
        end
    end
end