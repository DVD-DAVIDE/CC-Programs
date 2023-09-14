local check_freq = 10
local pull_filter = {
    "minecraft:hopper",
}
local push_filter = {
    "minecraft:chest",
    "minecraft:barrel",
    "sc-goodies:iron_chest",
    "sc-goodies:iron_barrel"
}
local periphs_pull = {}
local periphs_push = {}

for k, v in pairs(pull_filter) do
    table.insert(periphs_pull, peripheral.find(v))
end
for k, v in pairs(push_filter) do
    table.insert(periphs_push, peripheral.find())
end

while true do
    for _, source in pairs(periphs_pull) do
        for slot, item in pairs(source.list()) do
            local to_move = item.count
            for _, dest in pairs(periphs_push) do
                to_move = to_move - source.pushItems(peripheral.getName(dest), slot)
                if to_move == 0 then break end
            end
        end
    end
    sleep(check_freq)
end