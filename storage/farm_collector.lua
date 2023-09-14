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

for _, v in pairs(pull_filter) do
    for _, p in pairs({peripheral.find(v)}) do
        table.insert(periphs_pull, p)
    end
end
for _, v in pairs(push_filter) do
    for _, p in pairs({peripheral.find(v)}) do
        table.insert(periphs_push, p)
    end
end

while true do
    for _, source in pairs(periphs_pull) do
        for slot, item in pairs(source.list()) do
            local to_move = item.count
            for _, dest in pairs(periphs_push) do
                local moved = source.pushItems(peripheral.getName(dest), slot)
                print("Moved "..moved.." "..item.name)
                to_move = to_move - moved
                if to_move == 0 then break end
            end
        end
    end
    sleep(check_freq)
end