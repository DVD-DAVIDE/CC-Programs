turtle.select(1)
while true do
    turtle.suckUp(turtle.getItemSpace())
    if turtle.place() then
        turtle.select(2)
        turtle.dropDown()
        turtle.select(1)
    end
    sleep(30)
end