-- Boomerang Mining
-- Mines in a straight line 2 blocks high
-- Keeps track of its position with dead reckoning
-- Once it has exactly enough fuel to return to the startpoint it turns around
-- But first it attempts to refuel and keep going

position = 0

function main()
	local range = turtle.getFuelLevel()
	position = 0;
	
	while position < range do
		onward()
		range = turtle.getFuelLevel()
		if position < range then
			print('Fuel at 50%. Attempting to refuel...')
			if tryRefuel() then
				print('Refuel successful!')
			else
				print('No more fuel.')
			range = turtle.getFuelLevel()
		end
	end
	print('Midpoint reached.')
	goHome()
end

function onward()
	if turtle.detectDown() then
		turtle.digDown()
	end
	if turtle.forward() then
		position = position + 1
	else
		print('onward: Unable to move')
	end
	if turtle.detect() then
		turtle.dig()
	end
end

function goHome()
	print('Returning home')
	turtle.turnRight()
	turtle.turnRight()
	
	while position > 0 do
		if turtle.forward() then
			position = position - 1
		else
			print('goHome: Unable to move')
		end
	end
	
	-- Drop off contents
	for i = 1, 16 do
		turtle.select(i)
		turtle.drop()
	end
end

function tryRefuel()
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel() then
			return true
		end
	end
	return false
end

main()