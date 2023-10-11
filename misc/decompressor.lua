local output_side = "top"
local input_side = "bottom"

local drop = {
    ["front"]   = turtle.drop,
    ["top"]     = turtle.dropUp,
    ["bottom"]  = turtle.dropDown,
}

local suck = {
    ["front"]   = turtle.suck,
    ["top"]     = turtle.suckUp,
    ["bottom"]  = turtle.suckDown,
}

local function emptyInv()
    for i = 16, 1, -1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            drop[output_side]()
        end
    end
    turtle.select(1)
end

emptyInv()

while true do
    if suck[input_side]() then
        turtle.craft()
        emptyInv()
    else
        sleep(2.5)
    end
end
