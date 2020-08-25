-- TendSmelter.lua
​
function refuelSmelter()
	turtle.suckDown(64)
	turtle.dropUp(64)
end
​
function tendSmelter()
	local hopperData = turtle.inspectUp()
	-- Count how much charcoal is in the hopper 
	-- Possibly in hopperData.metdata?
	if fuelCount < 64 then
		refuelSmelter()
	end
end
​
while true
	tendSmelter()
	os.sleep(1)
end
