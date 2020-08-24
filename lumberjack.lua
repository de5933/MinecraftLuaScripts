SAPLING = 'minecraft:sapling'
LOG = 'minecraft:log'

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
	for i = 1, 16 do
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

chopTree()