-- Very simple harvest program
-- Watch the block below
-- If a block is detected, mine it
-- Drop results above (ideally into a chest)
-- Works well for cactus and sugarcane

while true do
	if turtle.detectDown() then
		turtle.digDown()
		for i = 1, 16 do
			if turtle.getItemCount(i) > 0 then
				turtle.select(i)
				turtle.dropUp()
			end
		end
	end
	sleep(1)
end