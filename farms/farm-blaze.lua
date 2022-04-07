-- Program for blaze farming, intended for melee turtles.
-- Simply attacks forever.
while turtle.getItemCount(16) == 0 do
    turtle.attack()
end