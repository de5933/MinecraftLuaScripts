-- Farm.lua v0.5
-- Turtle starts on block to the right of the back, rightmost block in the field
-- Turtle must be one block above the farmland
-- The field area must be walled off at the turtle's level
-- At least one crop must already be planted
-- The starting area must have a chest above the turtle containing fuel
-- And an empty chest beneath the turtle that will be filled with crops and seeds

WHEAT = 'minecraft:wheat'
CARROT = 'minecraft:carrots'
POTATO = 'minecraft:potatoes'

WHEATSEED = 'minecraft:wheat_seeds'

-- Moves turtle left, right, and forward
-- Movement stops upon reaching a block in the direction of movement
-- The specified function is evaluated before each movement
function iterateField(fn)
	local count = 0;

	turtle.turnLeft()

	print('Heading out')

	repeat
		turtle.forward()
		fn()
		turtle.turnRight()

		-- Go to the end of the field
		print('Processing strip')
		while not turtle.detect() do
			if (turtle.forward()) then
				count = count + 1
			end
			fn()
		end

		count = count + retreat()
		turtle.turnRight()
	until turtle.detect()

	-- Return home
	count = count + retreat()
	turtle.turnLeft()

	return count
end

function retreat()
	print('Retreating')
	local count = 0;
	turtle.turnRight()
	turtle.turnRight()

	while not turtle.detect() do
		if (turtle.forward()) then
			count = count + 1
		end
	end
	return count
end

-- Search the inventory for an item
-- Returns the first result for which predicate returns true
-- Both item and index are returned
function findItem(predicate)
	for i = 1, 16 do
		local item = turtle.getItemDetail(i)
		if predicate(item) then 
			return item, i
		end
	end
	return nil
end

function tryRefuel(targetLevel)
	if turtle.getFuelLevel() < targetLevel then
		turtle.refuel()
	end
end

function isRipe(blockData)
	if not blockData then
		return false
	end

	local name = blockData.name
	local age = blockData.metadata

	return (name == WHEAT or name == CARROT or name == POTATO) and age >= 7
end

function isSeed(itemData)
	if not itemData then
		return false
	end

	return itemData.name == WHEATSEED
		or itemData.name == CARROT
		or itemData.name == POTATO
end

function isCrop(itemData)
	if not itemData then
		return false
	end
	
	return itemData.name == WHEAT
		or itemData.name == CARROT
		or itemData.name == POTATO
end

function farmTile()
	local success, tile = turtle.inspectDown()

	if success and isRipe(tile) then
		-- Harvest
		print('Harvesting ', tile.name)
		turtle.digDown()
		success, tile = turtle.inspectDown()
	end

	if not success then
		-- Plough
		print('Ploughing ', tile.name)
		turtle.digDown()
		-- Plant seed
		local seed, index = findItem(isSeed)
		if seed == nil then
			print('No seeds to plant. :(')
		else
			turtle.select(index)
			print('Planting ', seed.name)
			if not turtle.placeDown() then
				print('Planting failed')
			end
		end
	end
end

function deposit()
	print('Dropping off harvested crops')
	-- Set aside 4 stacks of seeds
	-- Drop the remaining items
	-- Crops go in forward chest
	-- Seeds go in bottom chest

	-- MVP: Drop all items
	local seedCount = 0

	for i = 1, 16 do
		local item = turtle.getItemDetail(i)
		if isSeed(item) or isCrop(item) then
			if seedCount > (64*4) then
				turtle.select(i)
				turtle.dropDown()
			end
			seedCount = seedCount + item.count
		end
	end
end

turtle.suckUp()
tryRefuel(64)

while true do
	local distance = iterateField(farmTile)

	deposit()
	turtle.suckUp()
	tryRefuel(distance)
end
