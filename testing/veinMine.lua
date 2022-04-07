--[[-
  veinMiner from Lupus290's GitHub: https://github.com/Lupus590-CC/CC-Random-Code/
]]
local desireables = {
  ["minecraft:gold_ore"] = true,
  ["minecraft:iron_ore"] = true,
  ["minecraft:coal_ore"] = true,
  ["minecraft:nether_gold_ore"] = true,
  ["minecraft:lapis_ore"] = true,
  ["minecraft:diamond_ore"] = true,
  ["minecraft:redstone_ore"] = true,
  ["minecraft:emerald_ore"] = true,
  ["minecraft:nether_quartz_ore"] = true,
  ["powah:uraninite_ore_poor"] = true,
  ["powah:uraninite_ore"] = true,
  ["powah:uraninite_ore_dense"] = true,
  ["powah:dry_ice"] = true
}

local function isDesireable()
  local ok, item = turtle.inspect()
  return ok and desireables[item.name]
end
local function isDesireableUp()
  local ok, item = turtle.inspectUp()
  return ok and desireables[item.name]
end
local function isDesireableDown()
  local ok, item = turtle.inspectDown()
  return ok and desireables[item.name]
end

local function veinMine()
  for i = 1, 4 do
    if isDesireable() then
      turtle.dig()
      turtle.forward()
      veinMine()
      turtle.back()
    end
    turtle.turnRight()
  end
  if isDesireableUp() then
    turtle.digUp()
    turtle.up()
    veinMine()
    turtle.down()
  end
  if isDesireableDown() then
    turtle.digDown()
    turtle.down()
    veinMine()
    turtle.up()
  end
end

return veinMine