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
	local success, data = turtle.inspect()
	return success == false
end

function findItem(name)
	for i = 1, SLOTCOUNT do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		end
	end
	return nil
end

function plantTree()
	local tmpIndex = turtle.getSelectedSlot()
	local index = findItem(SAPLING)
	turtle.select(index)
	turtle.place()
	turtle.select(tmpIndex)
end

function chopTree()
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
	for i = 0, SLOTCOUNT do
		local data = turtle.getItemDetail(i)
		if data.name == LOG then
			turtle.select(i)
			turtle.dropDown()
		end
	end
	turtle.select(tmpIndex)
end

function refuel()
	if turtle.getFuelLevel() > 16 then
		return
	end

	local tmpIndex = turtle.getSelectedSlot()
	local index = findItem(LOG)
	if index then
		turtle.select(index)
		turtle.refuel(1)
	end
	turtle.select(tmpIndex)
end

while true do
	if isEmpty() then
		plantTree()
	elseif isLog then
		refuel()
		chopTree()
		plantTree()
	end

	os.sleep(1)
end
