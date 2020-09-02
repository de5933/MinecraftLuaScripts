-- Boomerang Mining
-- Mines in a straight line 2 blocks high
-- It digs ahead and up
-- Keeps track of its position with dead reckoning
-- Once it has exactly enough fuel to return to the startpoint it turns around
-- But first it attempts to refuel and keep going
-- Once it returns to the startpoint, it drops its contents downward

args = {...}

position = 0
customRange = false

function main(n)
	local range = turtle.getFuelLevel()
	if n and n < range then
		range = n
		customRange = true
	end

	position = 0;
	
	while position < range do
		print('Distance: ', position, '/', range)
		onward()
		if not customRange then
			range = turtle.getFuelLevel()
		end
		if not customRange and position >= range then
			print('Fuel at 50%. Attempting to refuel...')
			if tryRefuel() then
				print('Refuel successful!')
			else
				print('No more fuel.')
			end
			range = turtle.getFuelLevel()
		end
	end
	print('Midpoint reached.')
	goHome()
end

function onward()
	if turtle.detect() then
		turtle.dig()
	end
	if turtle.forward() then
		position = position + 1
	else
		print('onward(): Unable to move')
	end
	if turtle.detectUp() then
		turtle.digUp()
	end
end

function dropAll()
	print('Dropping off contents')
	-- Drop off contents
	for i = 1, 16 do
		if turtle.getItemCount(i) then
			turtle.select(i)
			turtle.dropDown()
		end
	end
end

function goHome()
	print('Returning home')
	turtle.turnRight()
	turtle.turnRight()
	
	while position > 0 do
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then
			position = position - 1
		else
			print('goHome(): Unable to move')
		end
	end

	turtle.turnRight()
	turtle.turnRight()
end

function tryRefuel()
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel() then
			return true
		end
	end
	print('No more fuel.')
	return false
end

main(tonumber(args[1]))