local shulker_side, output_side = "bottom", "top"

while true do
    local _, side = os.pullEvent("peripheral")
    if side == shulker_side then
        local shulker = peripheral.wrap(shulker_side)
        for slot, _ in pairs(shulker.list()) do
            shulker.pushItems(output_side, slot)
        end
    end
end