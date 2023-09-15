--- This script attempts to keep the player fully fed by checking their food level and scanning for food items.

--- Firstly we find a manipulator or neural interface and error if it is not there.
local modules = peripheral.find("manipulator") or peripheral.find("neuralInterface")
if not modules then
	error("Must have neural interface or manipulator", 0)
end

--- We require the entity sensor to get the food levels and the introspection module to access the player's
--- inventory. We use `hasModule` to ensure they are both there.
if not modules.hasModule("plethora:sensor") then
	error("The entity sensor is missing", 0)
end
if not modules.hasModule("plethora:introspection") then
	error("The introspection module is missing", 0)
end

--- We'll want to scan the player's inventory a lot so we cache it here.
local inv = modules.getInventory()

--- Instead of rescanning the inventory every time we cache the last slot we ate from. As we haven't searched for food
--- yet, we'll just use nil.
local cachedSlot = nil

--- We run this top level loop continuously, checking every 5 seconds to see if the player is hungry. This means we will
--- feed the player pretty quickly after they become hungry.
while true do
	--- We fetch the metadata about the current owner which includes food levels. We run this inner loop whilst the
	--- player is hungry to ensure they are fed quickly without a delay (which you would get if this ran in the top
	--- loop).
	local data = modules.getMetaOwner()
	while data.food.hungry do

        if not cachedSlot or not inv.consume(cachedSlot) then
            -- Find new slot for food
            for slot, meta in pairs(inv.list()) do
                if inv.consume(slot) then
                    print("Using food from slot " .. slot)
                    cachedSlot = slot
                    break
                end
            end
        end
		--- As the hungry flag may have changed we refetch the data and rerun the feeding loop.
		data = modules.getMetaOwner()
	end

	--- The player is now no longer hungry or we have no food so we sleep for a bit.
	sleep(5)
end