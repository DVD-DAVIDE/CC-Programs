while turtle.getFuelLevel() <= turtle.getFuelLimit() - 1000 do
    turtle.select(1)
    if not turtle.suck(1) then
        print("The turtle isn't oriented correctly, or there is no items in the chest.")
        break
    end
    if not turtle.refuel() then
        print("The item sucked from the chest cannot be used as fuel.")
        break
    end
    turtle.dropDown()
end

print("Fuel level: "..turtle.getFuelLevel())