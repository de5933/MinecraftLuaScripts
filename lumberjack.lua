SAPLING = 'minecraft:sapling'
LOG = 'minecraft:log'
SLOTCOUNT = 16

function isSapling()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == SAPLING
	end
	return false
end

function isLog()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == LOG
	end
	return false
end

function isEmpty()
	return not turtle.detect()
end

function findItem(name)
	for i = 1, SLOTCOUNT do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		else
			print('Could not find item: ', name)
		end
	end
	return nil
end

function plantTree()
	print('Planting tree')
	local tmpIndex = turtle.getSelectedSlot()
	local index = findItem(SAPLING)
	if not index then
		print('No saplings to plant. :(')
		return
	end
	turtle.select(index)
	turtle.place()
	turtle.select(tmpIndex)
end

function chopTree()
	print('Chopping tree')
	local y = 0

	while isLog() do
		if not turtle.dig() then
			print('Trying to dig...')
		end

		if turtle.detectUp() then
			turtle.digUp()
		end
		
		if turtle.up() then
			y = y + 1
		else
			print('Trying to move up...')
		end
	end

	while y > 0 do
		if turtle.down() then
			y = y - 1
		else
			print('Trying to move down...')
		end
	end

end

function depositWood()
	local tmpIndex = turtle.getSelectedSlot()
	local foundFuel = false
	for i = 1, SLOTCOUNT do
		local data = turtle.getItemDetail(i)
		if data and data.name == LOG then
			if foundFuel then
				print('Depositing logs')
				turtle.select(i)
				turtle.dropDown()
			else
				print('Setting aside logs for fuel')
				foundFuel = true
			end
		end
	end
	turtle.select(tmpIndex)
end

function refuel()
	if turtle.getFuelLevel() > 16 then
		return
	end

	print('Refueling...')
	local tmpIndex = turtle.getSelectedSlot()
	local index = findItem(LOG)
	if index then
		turtle.select(index)
		turtle.refuel(1)
		print('Refueling successful')
	else
		print('Could not find fuel')
	end
	turtle.select(tmpIndex)
end

function gatherDrops()
	print('Gathering dropped saplings')
	turtle.suck()
	turtle.turnRight()
	turtle.suck()
	turtle.turnRight()
	turtle.suck()
	turtle.turnRight()
	turtle.suck()
	turtle.turnRight()
end

while true do
	if isEmpty() then
		plantTree()
	elseif isLog() then
		refuel()
		chopTree()
		depositWood()
		plantTree()
	end
	gatherDrops()

	os.sleep(1)
end
